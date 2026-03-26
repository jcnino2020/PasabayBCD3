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
$booking_id = $data['booking_id'] ?? null;

if (empty($booking_id)) {
    send_json_response(400, ['error' => 'booking_id is required']);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

$stmt = $conn->prepare(
    "UPDATE pasabaybcd_bookings SET status = 'completed', completed_at = NOW() WHERE id = ?"
);
$stmt->bind_param("s", $booking_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        send_json_response(200, ['success' => true, 'message' => 'Booking marked as completed']);
    } else {
        send_json_response(404, ['error' => 'Booking not found or already completed']);
    }
} else {
    send_json_response(500, ['error' => 'Update failed: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>