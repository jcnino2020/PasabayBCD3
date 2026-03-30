<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
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

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

if ($user_id <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid or missing user_id.']);
    exit();
}

// Fetch transactions ordered by most recent first
$stmt = $conn->prepare(
    "SELECT id, user_id, label, amount,
            DATE_FORMAT(created_at, '%b %d, %Y') AS formatted_date
     FROM pasabaybcd_transactions
     WHERE user_id = ?
     ORDER BY created_at DESC
     LIMIT 50"
);

if ($stmt === false) {
    http_response_code(500);
    echo json_encode(['error' => 'SQL prepare failed: ' . $conn->error]);
    exit();
}

$stmt->bind_param('i', $user_id);
$stmt->execute();
$result = $stmt->get_result();

$transactions = [];
while ($row = $result->fetch_assoc()) {
    $transactions[] = [
        'id'             => (int) $row['id'],
        'label'          => $row['label'],
        'amount'         => (float) $row['amount'],
        'formatted_date' => $row['formatted_date'],
    ];
}

http_response_code(200);
echo json_encode($transactions);

$stmt->close();
$conn->close();
?>
