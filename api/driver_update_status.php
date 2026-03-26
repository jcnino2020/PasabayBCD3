<?php
// ============================================================
// API: Driver Update Booking Status
// POST { "booking_id": "BK-xxx", "status": "confirmed", "driver_id": 1 }
// Driver can move: pending -> confirmed -> in_transit -> completed
// Driver can also: pending -> cancelled
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

$data       = json_decode(file_get_contents('php://input'), true);
$booking_id = $data['booking_id'] ?? null;
$new_status = $data['status'] ?? null;
$driver_id  = $data['driver_id'] ?? null;

$allowed = ['confirmed', 'in_transit', 'completed', 'cancelled'];

if (empty($booking_id) || empty($new_status) || empty($driver_id)) {
    send_json_response(400, ['error' => 'booking_id, status, and driver_id are required']);
}

if (!in_array($new_status, $allowed)) {
    send_json_response(400, ['error' => 'Invalid status. Allowed: ' . implode(', ', $allowed)]);
}

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

// Verify this booking belongs to the driver's truck
$verify = $conn->prepare(
    "SELECT b.id FROM pasabaybcd_bookings b
     JOIN pasabaybcd_trucks t ON t.id = b.truck_id
     WHERE b.id = ? AND t.driver_id = ?"
);
$verify->bind_param("si", $booking_id, $driver_id);
$verify->execute();
$vres = $verify->get_result();
if ($vres->num_rows === 0) {
    send_json_response(403, ['error' => 'This booking does not belong to your truck']);
}
$verify->close();

// Update status
if ($new_status === 'completed') {
    $stmt = $conn->prepare(
        "UPDATE pasabaybcd_bookings SET status = ?, completed_at = NOW() WHERE id = ?"
    );
} else {
    $stmt = $conn->prepare(
        "UPDATE pasabaybcd_bookings SET status = ? WHERE id = ?"
    );
}

$stmt->bind_param("ss", $new_status, $booking_id);

if ($stmt->execute() && $stmt->affected_rows > 0) {
    // If confirming, also insert a notification for the merchant
    if ($new_status === 'confirmed') {
        // Get user_id for this booking
        $uid_stmt = $conn->prepare("SELECT user_id, driver_name FROM pasabaybcd_bookings WHERE id = ?");
        $uid_stmt->bind_param("s", $booking_id);
        $uid_stmt->execute();
        $uid_res = $uid_stmt->get_result()->fetch_assoc();
        $uid_stmt->close();

        if ($uid_res) {
            $user_id     = $uid_res['user_id'];
            $driver_name = $uid_res['driver_name'];
            $notif_stmt  = $conn->prepare(
                "INSERT INTO pasabaybcd_notifications (user_id, type, title, body)
                 VALUES (?, 'booking', 'Booking Confirmed!', ?)"
            );
            $notif_body = "Driver {$driver_name} has accepted your booking {$booking_id}.";
            $notif_stmt->bind_param("is", $user_id, $notif_body);
            $notif_stmt->execute();
            $notif_stmt->close();
        }
    }

    $stmt->close();
    $conn->close();
    send_json_response(200, [
        'success'    => true,
        'message'    => "Booking status updated to '{$new_status}'",
        'booking_id' => $booking_id,
        'status'     => $new_status
    ]);
} else {
    send_json_response(404, ['error' => 'Booking not found or already at that status']);
}
?>