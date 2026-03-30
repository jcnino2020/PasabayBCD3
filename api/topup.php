<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed. Use POST.']);
    exit();
}

// --- Database Credentials ---
$servername = "ov3.238.mytemp.website";
$username   = "jac";
$password   = "43IG_fI]mw[E";
$dbname     = "bsit3b";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]);
    exit();
}

$body = json_decode(file_get_contents('php://input'), true);
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON body.']);
    exit();
}

$user_id        = isset($body['user_id'])        ? intval($body['user_id'])          : 0;
$amount         = isset($body['amount'])         ? floatval($body['amount'])          : 0.0;
$payment_method = isset($body['payment_method']) ? trim($body['payment_method'])      : '';

if ($user_id <= 0 || $amount <= 0 || empty($payment_method)) {
    http_response_code(400);
    echo json_encode(['error' => 'user_id, amount, and payment_method are required.']);
    exit();
}

// --- Begin transaction ---
$conn->begin_transaction();

try {
    // 1. Update wallet balance
    $stmt = $conn->prepare(
        "UPDATE pasabaybcd_users SET wallet_balance = wallet_balance + ? WHERE id = ?"
    );
    if (!$stmt) throw new Exception('Prepare failed (balance update): ' . $conn->error);
    $stmt->bind_param('di', $amount, $user_id);
    if (!$stmt->execute()) throw new Exception('Execute failed (balance update): ' . $stmt->error);
    if ($stmt->affected_rows === 0) throw new Exception('User not found.');
    $stmt->close();

    // 2. Record transaction
    $label = 'Top Up via ' . $payment_method;
    $stmt2 = $conn->prepare(
        "INSERT INTO pasabaybcd_transactions (user_id, label, amount) VALUES (?, ?, ?)"
    );
    if (!$stmt2) throw new Exception('Prepare failed (insert tx): ' . $conn->error);
    $stmt2->bind_param('isd', $user_id, $label, $amount);
    if (!$stmt2->execute()) throw new Exception('Execute failed (insert tx): ' . $stmt2->error);
    $stmt2->close();

    $conn->commit();

    // Return updated balance
    $stmt3 = $conn->prepare("SELECT wallet_balance FROM pasabaybcd_users WHERE id = ?");
    $stmt3->bind_param('i', $user_id);
    $stmt3->execute();
    $res = $stmt3->get_result()->fetch_assoc();
    $stmt3->close();

    http_response_code(200);
    echo json_encode([
        'success'         => true,
        'message'         => 'Top-up successful.',
        'new_balance'     => (float) $res['wallet_balance'],
    ]);

} catch (Exception $e) {
    $conn->rollback();
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}

$conn->close();
?>
