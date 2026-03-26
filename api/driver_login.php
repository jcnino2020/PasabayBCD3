<?php
// ============================================================
// API: Driver Login
// POST { "driver_id": 1, "phone_number": "09171234567" }
// For capstone demo: auth by driver_id + phone_number combo
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

$servername = "ov3.238.mytemp.website";
$username   = "jac";
$password   = "43IG_fI]mw[E";
$dbname     = "bsit3b";

function send_json_response($code, $data) {
    http_response_code($code);
    echo json_encode($data);
    exit();
}

$data      = json_decode(file_get_contents('php://input'), true);
$driver_id = $data['driver_id'] ?? null;
$phone     = trim($data['phone_number'] ?? '');

if (empty($driver_id) || empty($phone)) {
    send_json_response(400, ['error' => 'driver_id and phone_number are required']);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

// Fetch driver + their truck in one query
$stmt = $conn->prepare(
    "SELECT d.id, d.driver_name, d.rating, d.profile_photo_url, d.is_vaccinated, d.phone_number,
            t.id AS truck_id, t.type AS truck_type, t.plate_number, t.capacity_kg,
            t.capacity_cbm, t.base_price, t.current_route, t.depart_time, t.status AS truck_status
     FROM pasabaybcd_drivers d
     LEFT JOIN pasabaybcd_trucks t ON t.driver_id = d.id
     WHERE d.id = ? AND d.phone_number = ?"
);
$stmt->bind_param("is", $driver_id, $phone);
$stmt->execute();
$result = $stmt->get_result();
$driver = $result->fetch_assoc();
$stmt->close();
$conn->close();

if (!$driver) {
    send_json_response(401, ['error' => 'Invalid driver ID or phone number']);
}

// Cast types
$driver['id']          = (int)$driver['id'];
$driver['truck_id']    = (int)$driver['truck_id'];
$driver['is_vaccinated'] = (bool)$driver['is_vaccinated'];
$driver['rating']      = (float)$driver['rating'];
$driver['capacity_kg'] = (float)$driver['capacity_kg'];
$driver['capacity_cbm']= (float)$driver['capacity_cbm'];
$driver['base_price']  = (float)$driver['base_price'];

send_json_response(200, $driver);
?>