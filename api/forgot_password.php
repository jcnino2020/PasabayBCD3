<?php
// ============================================================
// API: Forgot Password
// POST { "email": "user@email.com" }
// Always returns success (anti-enumeration pattern)
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
$data  = json_decode(file_get_contents('php://input'), true);
$email = trim($data['email'] ?? '');

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    send_json_response(400, ['error' => 'A valid email address is required']);
}

// --- Database Connection ---
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

// --- Check if user exists (silently — don't reveal to client) ---
$stmt = $conn->prepare("SELECT id FROM pasabaybcd_users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$user   = $result->fetch_assoc();
$stmt->close();

if ($user) {
    // --- Generate a secure token ---
    $token      = bin2hex(random_bytes(32)); // 64-char hex string
    $expires_at = date('Y-m-d H:i:s', strtotime('+1 hour'));

    // --- Store token in DB ---
    // Delete any old tokens for this email first
    $del = $conn->prepare("DELETE FROM pasabaybcd_password_resets WHERE email = ?");
    $del->bind_param("s", $email);
    $del->execute();
    $del->close();

    $ins = $conn->prepare(
        "INSERT INTO pasabaybcd_password_resets (email, token, expires_at) VALUES (?, ?, ?)"
    );
    $ins->bind_param("sss", $email, $token, $expires_at);
    $ins->execute();
    $ins->close();

    // --- In a real app, send an email with the reset link here ---
    // For the capstone demo, we just log/skip the email sending.
    // $reset_link = "https://yourapp.com/reset-password?token=" . $token;
    // mail($email, "Reset your PasabayBCD password", "Click here: " . $reset_link);
}

$conn->close();

// --- Always return the same response (anti-enumeration) ---
send_json_response(200, [
    'success' => true,
    'message' => 'If that email is registered, a reset link has been sent.'
]);
?>