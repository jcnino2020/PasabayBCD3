<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$servername = "ov3.238.mytemp.website";
$username = "jac";
$password = "43IG_fI]mw[E";
$dbname = "bsit3b";

$user_id = $_GET['user_id'] ?? null;
if (empty($user_id) || !is_numeric($user_id)) {
    http_response_code(400);
    echo json_encode(['error' => 'A valid User ID is required']);
    exit();
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit();
}

$stmt = $conn->prepare("SELECT id, email, merchant_name, market_location, is_kyc_verified, wallet_balance, role FROM pasabaybcd_users WHERE id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($user = $result->fetch_assoc()) {
    echo json_encode($user);
} else {
    http_response_code(404);
    echo json_encode(['error' => 'User not found']);
}

$stmt->close();
$conn->close();
?>