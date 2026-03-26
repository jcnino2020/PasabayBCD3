<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// --- Database Credentials ---
$servername = "ov3.238.mytemp.website";
$username = "jac";
$password = "43IG_fI]mw[E";
$dbname = "bsit3b";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]);
    exit();
}

// --- PROCESS LOGIN ---
if (!isset($_POST['payload'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing payload data.']);
    exit();
}

$data = json_decode($_POST['payload'], true);

if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON received: ' . json_last_error_msg()]);
    exit();
}

$email = $data['email'] ?? null;
$password = $data['password'] ?? null;

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['error' => 'Email and password are required.']);
    exit();
}

// --- AUTHENTICATE USER ---
// FIX: Added `role` to SELECT so Flutter can route driver vs passenger
$stmt = $conn->prepare("SELECT id, email, password_hash, full_name, merchant_name, market_location, profile_photo_url, is_kyc_verified, wallet_balance, role FROM pasabaybcd_users WHERE email = ?");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(['error' => 'SQL prepare failed: ' . $conn->error]);
    exit();
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($user = $result->fetch_assoc()) {
    if (password_verify($password, $user['password_hash'])) {
        unset($user['password_hash']);

        if (empty($user['merchant_name']) && !empty($user['full_name'])) {
            $user['merchant_name'] = $user['full_name'];
        }

        // Default role to 'passenger' if not set in DB
        if (empty($user['role'])) {
            $user['role'] = 'passenger';
        }

        http_response_code(200);
        echo json_encode($user);
    } else {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid email or password.']);
    }
} else {
    http_response_code(401);
    echo json_encode(['error' => 'Invalid email or password.']);
}

$stmt->close();
$conn->close();
?>