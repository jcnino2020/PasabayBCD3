<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$servername = "ov3.238.mytemp.website";
$username = "jac";
$password = "43IG_fI]mw[E";
$dbname = "bsit3b";

function send_json_response($statusCode, $data) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

// GET: fetch bookings for a user
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $user_id = $_GET['user_id'] ?? null;
    if (empty($user_id)) {
        send_json_response(400, ['error' => 'user_id is required']);
    }

    $conn = new mysqli($servername, $username, $password, $dbname);
    if ($conn->connect_error) {
        send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
    }

    $stmt = $conn->prepare(
        "SELECT id, user_id, truck_id, driver_name, cargo_category, cargo_weight_kg, cargo_quantity, estimated_fee, cargo_photo_url, status, created_at, completed_at
        FROM pasabaybcd_bookings WHERE user_id = ? ORDER BY created_at DESC"
    );
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $bookings = [];
    while ($row = $result->fetch_assoc()) {
        $row['user_id'] = (int)$row['user_id'];
        $row['truck_id'] = (int)$row['truck_id'];
        $row['cargo_weight_kg'] = (float)$row['cargo_weight_kg'];
        $row['cargo_quantity'] = (int)$row['cargo_quantity'];
        $row['estimated_fee'] = (float)$row['estimated_fee'];
        $bookings[] = $row;
    }
    $stmt->close();
    $conn->close();
    echo json_encode($bookings);
    exit();
}

// POST: create new booking
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $cargo_photo_url = null;
    if (isset($_FILES['cargo_photo']) && $_FILES['cargo_photo']['error'] == 0) {
        $upload_dir = '../uploads/bookings/';
        if (!is_dir($upload_dir)) {
            if (!mkdir($upload_dir, 0777, true)) {
                send_json_response(500, ['error' => 'Failed to create upload directory.']);
            }
        }
        $file_extension = pathinfo($_FILES['cargo_photo']['name'], PATHINFO_EXTENSION);
        $file_name = "booking-" . ($_POST['user_id'] ?? '0') . "-" . time() . "." . $file_extension;
        $target_file = $upload_dir . $file_name;
        if (move_uploaded_file($_FILES['cargo_photo']['tmp_name'], $target_file)) {
            $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
            $host = $_SERVER['HTTP_HOST'];
            $cargo_photo_url = "$protocol://$host/pasabaybcd/uploads/bookings/" . $file_name;
        } else {
            send_json_response(500, ['error' => 'Failed to move uploaded file.']);
        }
    } else {
        send_json_response(400, ['error' => 'Cargo photo is required.']);
    }

    $user_id = $_POST['user_id'] ?? 0;
    $truck_id = $_POST['truck_id'] ?? '';
    $driver_name = $_POST['driver_name'] ?? '';
    $cargo_category = $_POST['cargo_category'] ?? '';
    $weight_kg = $_POST['weight_kg'] ?? 0;
    $quantity = $_POST['quantity'] ?? 0;
    $estimated_fee = $_POST['estimated_fee'] ?? 0;

    // FIX: Generate unique booking ID (varchar primary key, not auto-increment)
    $booking_id = "BK-" . time() . "-" . rand(1000, 9999);

    $conn = new mysqli($servername, $username, $password, $dbname);
    if ($conn->connect_error) {
        send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
    }

    $stmt = $conn->prepare(
        "INSERT INTO pasabaybcd_bookings (id, user_id, truck_id, driver_name, cargo_category, cargo_weight_kg, cargo_quantity, estimated_fee, cargo_photo_url, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')"
    );
    if (!$stmt) {
        send_json_response(500, ['error' => 'SQL prepare failed: ' . $conn->error]);
    }
    $stmt->bind_param("sisssdids", $booking_id, $user_id, $truck_id, $driver_name, $cargo_category, $weight_kg, $quantity, $estimated_fee, $cargo_photo_url);

    if ($stmt->execute()) {
        $result_stmt = $conn->prepare("SELECT * FROM pasabaybcd_bookings WHERE id = ?");
        $result_stmt->bind_param("s", $booking_id);
        $result_stmt->execute();
        $result = $result_stmt->get_result();
        $new_booking = $result->fetch_assoc();
        $result_stmt->close();
        send_json_response(201, ['message' => 'Booking created successfully', 'booking' => $new_booking]);
    } else {
        send_json_response(500, ['error' => 'Booking creation failed: ' . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
    exit();
}

send_json_response(405, ['error' => 'Method not allowed']);
?>