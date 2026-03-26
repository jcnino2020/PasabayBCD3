<?php
// ============================================================
// API: Driver Bookings
// GET  ?driver_id=1&filter=pending    -> pending requests
// GET  ?driver_id=1&filter=active     -> confirmed + in_transit
// GET  ?driver_id=1&filter=history    -> completed + cancelled
// GET  ?driver_id=1&filter=all        -> everything
// ============================================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit(); }

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Only GET method is accepted']);
    exit();
}

$servername = "ov3.238.mytemp.website";
$username   = "jac";
$password   = "43IG_fI]mw[E";
$dbname     = "bsit3b";

function send_json_response($code, $data) {
    http_response_code($code);
    echo json_encode($data);
    exit();
}

$driver_id = $_GET['driver_id'] ?? null;
$filter    = $_GET['filter'] ?? 'pending';

if (empty($driver_id)) {
    send_json_response(400, ['error' => 'driver_id is required']);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

// Build status filter
$status_clause = '';
switch ($filter) {
    case 'pending':
        $status_clause = "AND b.status = 'pending'";
        break;
    case 'active':
        $status_clause = "AND b.status IN ('confirmed', 'in_transit')";
        break;
    case 'history':
        $status_clause = "AND b.status IN ('completed', 'cancelled')";
        break;
    default:
        $status_clause = '';
}

$sql = "SELECT b.id, b.user_id, b.truck_id, b.driver_name,
               b.cargo_category, b.cargo_weight_kg, b.cargo_quantity,
               b.estimated_fee, b.cargo_photo_url, b.status,
               b.created_at, b.completed_at,
               u.merchant_name, u.market_location, u.profile_photo_url AS merchant_photo
        FROM pasabaybcd_bookings b
        JOIN pasabaybcd_trucks t ON t.id = b.truck_id
        JOIN pasabaybcd_users u ON u.id = b.user_id
        WHERE t.driver_id = ?
        $status_clause
        ORDER BY b.created_at DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $driver_id);
$stmt->execute();
$result = $stmt->get_result();

$bookings = [];
while ($row = $result->fetch_assoc()) {
    $row['user_id']         = (int)$row['user_id'];
    $row['truck_id']        = (int)$row['truck_id'];
    $row['cargo_weight_kg'] = (float)$row['cargo_weight_kg'];
    $row['cargo_quantity']  = (int)$row['cargo_quantity'];
    $row['estimated_fee']   = (float)$row['estimated_fee'];
    $bookings[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode($bookings);
?>