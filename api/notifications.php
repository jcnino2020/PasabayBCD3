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

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    send_json_response(500, ['error' => 'Database connection failed: ' . $conn->connect_error]);
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $user_id = $_GET['user_id'] ?? null;
    if (empty($user_id)) {
        send_json_response(400, ['error' => 'user_id is required']);
    }

    $stmt = $conn->prepare(
        "SELECT id, user_id, type, title, body, is_read, created_at FROM pasabaybcd_notifications WHERE user_id = ? ORDER BY created_at DESC"
    );
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $notifications = [];
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $row['user_id'] = (int)$row['user_id'];
        $row['is_read'] = (int)$row['is_read'];
        $notifications[] = $row;
    }
    $stmt->close();
    echo json_encode($notifications);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $notification_id = $data['notification_id'] ?? null;
    $user_id = $data['user_id'] ?? null;
    $mark_all = $data['mark_all'] ?? false;

    if ($mark_all && !empty($user_id)) {
        $stmt = $conn->prepare("UPDATE pasabaybcd_notifications SET is_read = 1 WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $affected = $stmt->affected_rows;
        $stmt->close();
        send_json_response(200, ['success' => true, 'message' => "$affected notification(s) marked as read"]);
    }

    if (!empty($notification_id)) {
        $stmt = $conn->prepare("UPDATE pasabaybcd_notifications SET is_read = 1 WHERE id = ?");
        $stmt->bind_param("i", $notification_id);
        $stmt->execute();
        $stmt->close();
        send_json_response(200, ['success' => true, 'message' => 'Notification marked as read']);
    }

    send_json_response(400, ['error' => 'notification_id or (user_id + mark_all) is required']);
}

http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
$conn->close();
?>