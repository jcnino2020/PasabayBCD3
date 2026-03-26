<?php
// ============================================================
// API: Driver Trip History + Stats
// GET  ?driver_id=1            -> completed trips with totals
// GET  ?driver_id=1&stats=1    -> summary stats only
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

$driver_id  = $_GET['driver_id'] ?? null;
$stats_only = $_GET['stats'] ?? null;

if (empty($driver_id)) {
    send_json_response(400, ['error' => 'driver_id is required']);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

if ($stats_only) {
    // Return summary stats for the driver dashboard
    $stmt = $conn->prepare(
        "SELECT
            COUNT(*) AS total_trips,
            COALESCE(SUM(b.estimated_fee), 0) AS total_earnings,
            COALESCE(AVG(r.rating), 0) AS average_rating,
            COUNT(CASE WHEN b.status = 'completed' THEN 1 END) AS completed_trips,
            COUNT(CASE WHEN b.status = 'cancelled' THEN 1 END) AS cancelled_trips
         FROM pasabaybcd_bookings b
         JOIN pasabaybcd_trucks t ON t.id = b.truck_id
         LEFT JOIN pasabaybcd_ratings r ON r.driver_id = ?
         WHERE t.driver_id = ?"
    );
    $stmt->bind_param("ii", $driver_id, $driver_id);
    $stmt->execute();
    $stats = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    $conn->close();

    $stats['total_trips']      = (int)$stats['total_trips'];
    $stats['completed_trips']  = (int)$stats['completed_trips'];
    $stats['cancelled_trips']  = (int)$stats['cancelled_trips'];
    $stats['total_earnings']   = (float)$stats['total_earnings'];
    $stats['average_rating']   = round((float)$stats['average_rating'], 1);

    send_json_response(200, $stats);
}

// Full history with merchant info
$stmt = $conn->prepare(
    "SELECT b.id, b.user_id, b.cargo_category, b.cargo_weight_kg,
            b.cargo_quantity, b.estimated_fee, b.status,
            b.created_at, b.completed_at,
            u.merchant_name, u.market_location
     FROM pasabaybcd_bookings b
     JOIN pasabaybcd_trucks t ON t.id = b.truck_id
     JOIN pasabaybcd_users u ON u.id = b.user_id
     WHERE t.driver_id = ? AND b.status IN ('completed', 'cancelled')
     ORDER BY b.created_at DESC"
);
$stmt->bind_param("i", $driver_id);
$stmt->execute();
$result = $stmt->get_result();

$history = [];
while ($row = $result->fetch_assoc()) {
    $row['user_id']         = (int)$row['user_id'];
    $row['cargo_weight_kg'] = (float)$row['cargo_weight_kg'];
    $row['cargo_quantity']  = (int)$row['cargo_quantity'];
    $row['estimated_fee']   = (float)$row['estimated_fee'];
    $history[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode($history);
?>