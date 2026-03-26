<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Only GET method is accepted']);
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

$user_id = $_GET['user_id'] ?? null;
if (empty($user_id)) {
    send_json_response(400, ['error' => 'user_id is required']);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

$stmt = $conn->prepare(
    "SELECT id, user_id, truck_id, driver_name, cargo_category, cargo_weight_kg, cargo_quantity, estimated_fee, cargo_photo_url, status, created_at, completed_at
    FROM pasabaybcd_bookings
    WHERE user_id = ?
    ORDER BY created_at DESC"
);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$bookings = [];
while ($row = $result->fetch_assoc()) {
    $row['user_id'] = (int)$row['user_id'];
    $row['truck_id'] = (int)$row['truck_id'];
    $row['cargo_weight_kg'] = (float)$row['cargo_weight_kg'];
    $row['cargo_quantity'] = (int)$row['cargo_quantity'];
    $row['estimated_fee'] = (float)$row['estimated_fee'];
    $bookings[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode($bookings);
?>