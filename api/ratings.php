<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Only POST method is accepted']);
    exit();
}

$servername = "ov3.238.mytemp.website";
$username = "jac";
$password = "43IG_fI]mw[E";
$dbname = "bsit3b";

function send_json_response($statusCode, $data) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

$data = json_decode(file_get_contents('php://input'), true);

$user_id = $data['user_id'] ?? null;
$driver_id = $data['driver_id'] ?? null;
$booking_id = $data['booking_id'] ?? null;
$rating = $data['rating'] ?? null;
$tags = $data['tags'] ?? '';
$review_text = $data['review_text'] ?? '';

if (empty($user_id) || empty($driver_id) || empty($rating)) {
    send_json_response(400, ['error' => 'user_id, driver_id, and rating are required']);
}
if (!is_numeric($rating) || $rating < 1 || $rating > 5) {
    send_json_response(400, ['error' => 'Rating must be between 1 and 5']);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

$conn->begin_transaction();

try {
    $stmt = $conn->prepare(
        "INSERT INTO pasabaybcd_ratings (user_id, driver_id, booking_id, rating, tags, review_text) VALUES (?, ?, ?, ?, ?, ?)"
    );
    $stmt->bind_param("iisiss", $user_id, $driver_id, $booking_id, $rating, $tags, $review_text);
    $stmt->execute();
    $rating_id = $stmt->insert_id;
    $stmt->close();

    $stmt2 = $conn->prepare(
        "UPDATE pasabaybcd_drivers SET rating = (SELECT AVG(rating) FROM pasabaybcd_ratings WHERE driver_id = ?) WHERE id = ?"
    );
    $stmt2->bind_param("ii", $driver_id, $driver_id);
    $stmt2->execute();
    $stmt2->close();

    $conn->commit();
    send_json_response(201, ['success' => true, 'message' => 'Rating submitted successfully', 'rating_id' => $rating_id]);
} catch (Exception $e) {
    $conn->rollback();
    send_json_response(500, ['error' => 'Failed to submit rating: ' . $e->getMessage()]);
}

$conn->close();
?>