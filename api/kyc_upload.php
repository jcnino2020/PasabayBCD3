<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$servername = "ov3.238.mytemp.website";
$username = "jac";
$password = "43IG_fI]mw[E";
$dbname = "bsit3b";

function send_json_response($statusCode, $data) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    send_json_response(405, ['error' => 'Method Not Allowed']);
}

$user_id = $_POST['user_id'] ?? null;
$full_name = $_POST['full_name'] ?? null;
$business_permit_number = $_POST['business_permit_number'] ?? null;

if (!$user_id || !$full_name || !$business_permit_number) {
    send_json_response(400, ['error' => 'Missing required fields (user_id, full_name, business_permit_number).']);
}

$id_photo_url = null;
if (isset($_FILES['id_photo']) && $_FILES['id_photo']['error'] == 0) {
    $upload_dir = '../uploads/kyc/';
    if (!is_dir($upload_dir)) {
        if (!mkdir($upload_dir, 0777, true)) {
            send_json_response(500, ['error' => 'Failed to create upload directory.']);
        }
    }
    $file_extension = pathinfo($_FILES['id_photo']['name'], PATHINFO_EXTENSION);
    $file_name = "kyc-{$user_id}-" . time() . "." . $file_extension;
    $target_file = $upload_dir . $file_name;
    if (move_uploaded_file($_FILES['id_photo']['tmp_name'], $target_file)) {
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
        $host = $_SERVER['HTTP_HOST'];
        $id_photo_url = "$protocol://$host/pasabaybcd/uploads/kyc/" . $file_name;
    } else {
        send_json_response(500, ['error' => 'Failed to move uploaded file.']);
    }
} else {
    send_json_response(400, ['error' => 'ID photo is required.']);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

$stmt = $conn->prepare(
    "UPDATE pasabaybcd_users SET full_name = ?, business_permit_number = ?, id_photo_url = ?, is_kyc_verified = 1 WHERE id = ?"
);
if (!$stmt) {
    send_json_response(500, ['error' => 'SQL prepare failed: ' . $conn->error]);
}
$stmt->bind_param("sssi", $full_name, $business_permit_number, $id_photo_url, $user_id);

if ($stmt->execute()) {
    send_json_response(200, ['message' => 'KYC verification submitted successfully.']);
} else {
    send_json_response(500, ['error' => 'Failed to update user record: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>