<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$servername = "ov3.238.mytemp.website";
$username = "jac";
$password = "43IG_fI]mw[E";
$dbname = "bsit3b";

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

$name          = $data['name'] ?? null;
$email         = $data['email'] ?? null;
$password      = $data['password'] ?? null;
$merchantName  = $data['merchant_name'] ?? '';

if (empty($name) || empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['error' => 'Please fill in all fields.']);
    exit();
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid email format.']);
    exit();
}
if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(['error' => 'Password must be at least 6 characters.']);
    exit();
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]);
    exit();
}

$stmt = $conn->prepare("SELECT id FROM pasabaybcd_users WHERE email = ?");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(['error' => 'SQL prepare failed (SELECT): ' . $conn->error]);
    exit();
}
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    http_response_code(409);
    echo json_encode(['error' => 'An account with this email already exists.']);
    $stmt->close();
    $conn->close();
    exit();
}
$stmt->close();

$hashed_password = password_hash($password, PASSWORD_DEFAULT);

$stmt = $conn->prepare("INSERT INTO pasabaybcd_users (full_name, email, password_hash, merchant_name) VALUES (?, ?, ?, ?)");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(['error' => 'SQL prepare failed (INSERT): ' . $conn->error]);
    exit();
}
$stmt->bind_param("ssss", $name, $email, $hashed_password, $merchantName);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(['message' => 'User registered successfully.']);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to execute statement (INSERT): ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
