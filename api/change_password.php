<?php
// ============================================================
// API: Change Password
// POST { "user_id": 1, "current_password": "old", "new_password": "new" }
// Used from the Settings / Profile screen
// ============================================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit(); }

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Only POST method is accepted']);
    exit();
}

// --- Database Credentials ---
$servername = "ov3.238.mytemp.website";
$username   = "jac";
$password   = "43IG_fI]mw[E";
$dbname     = "bsit3b";

// --- Response Helper ---
function send_json_response($statusCode, $data) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

// --- Read JSON Body ---
$data             = json_decode(file_get_contents('php://input'), true);
$user_id          = $data['user_id'] ?? null;
$current_password = $data['current_password'] ?? null;
$new_password     = $data['new_password'] ?? null;

// --- Validate ---
if (empty($user_id) || empty($current_password) || empty($new_password)) {
    send_json_response(400, ['error' => 'user_id, current_password, and new_password are all required']);
}

if (strlen($new_password) < 6) {
    send_json_response(400, ['error' => 'New password must be at least 6 characters']);
}

if ($current_password === $new_password) {
    send_json_response(400, ['error' => 'New password must be different from the current password']);
}

// --- Database Connection ---
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

// --- Fetch current password hash ---
$stmt = $conn->prepare("SELECT password_hash FROM pasabaybcd_users WHERE id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();
$user   = $result->fetch_assoc();
$stmt->close();

if (!$user) {
    send_json_response(404, ['error' => 'User not found']);
}

// --- Verify current password ---
if (!password_verify($current_password, $user['password_hash'])) {
    send_json_response(401, ['error' => 'Current password is incorrect']);
}

// --- Hash new password and update ---
$new_hash = password_hash($new_password, PASSWORD_DEFAULT);

$upd = $conn->prepare("UPDATE pasabaybcd_users SET password_hash = ? WHERE id = ?");
$upd->bind_param("si", $new_hash, $user_id);

if ($upd->execute()) {
    $upd->close();
    $conn->close();
    send_json_response(200, [
        'success' => true,
        'message' => 'Password changed successfully'
    ]);
} else {
    send_json_response(500, ['error' => 'Failed to update password: ' . $upd->error]);
}
?>