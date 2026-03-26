<?php
// ============================================================
// API: Get Booking Status (used by driver_confirmation_screen
// to poll for confirmation every 5 seconds)
//
// GET  ?booking_id=BK-xxx         -> returns booking row
// POST { "booking_id": "BK-xxx", "status": "confirmed" }
//      -> manually update status (admin/driver side)
// ============================================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit(); }

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

// --- Database Connection ---
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

// ============================================================
// GET — Poll booking status
// Called by driver_confirmation_screen every 5 seconds
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $booking_id = $_GET['booking_id'] ?? null;

    if (empty($booking_id)) {
        send_json_response(400, ['error' => 'booking_id is required']);
    }

    $stmt = $conn->prepare(
        "SELECT id, user_id, truck_id, driver_name, cargo_category,
                cargo_weight_kg, cargo_quantity, estimated_fee,
                cargo_photo_url, status, created_at, completed_at
         FROM pasabaybcd_bookings
         WHERE id = ?"
    );
    $stmt->bind_param("s", $booking_id);
    $stmt->execute();
    $result  = $stmt->get_result();
    $booking = $result->fetch_assoc();
    $stmt->close();
    $conn->close();

    if (!$booking) {
        send_json_response(404, ['error' => 'Booking not found']);
    }

    // Cast types for clean JSON
    $booking['user_id']        = (int)$booking['user_id'];
    $booking['truck_id']       = (int)$booking['truck_id'];
    $booking['cargo_weight_kg']= (float)$booking['cargo_weight_kg'];
    $booking['cargo_quantity'] = (int)$booking['cargo_quantity'];
    $booking['estimated_fee']  = (float)$booking['estimated_fee'];

    send_json_response(200, $booking);
}

// ============================================================
// POST — Update booking status
// Allowed statuses: pending, confirmed, in_transit, completed, cancelled
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data       = json_decode(file_get_contents('php://input'), true);
    $booking_id = $data['booking_id'] ?? null;
    $new_status = $data['status'] ?? null;

    $allowed_statuses = ['pending', 'confirmed', 'in_transit', 'completed', 'cancelled'];

    if (empty($booking_id) || empty($new_status)) {
        send_json_response(400, ['error' => 'booking_id and status are required']);
    }

    if (!in_array($new_status, $allowed_statuses)) {
        send_json_response(400, [
            'error' => 'Invalid status. Must be one of: ' . implode(', ', $allowed_statuses)
        ]);
    }

    // Set completed_at only when marking as completed
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

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            $stmt->close();
            $conn->close();
            send_json_response(200, [
                'success'    => true,
                'message'    => "Booking status updated to '{$new_status}'",
                'booking_id' => $booking_id,
                'status'     => $new_status
            ]);
        } else {
            send_json_response(404, ['error' => 'Booking not found or status already set to that value']);
        }
    } else {
        send_json_response(500, ['error' => 'Update failed: ' . $stmt->error]);
    }
}

// If method is neither GET nor POST
http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
$conn->close();
?>