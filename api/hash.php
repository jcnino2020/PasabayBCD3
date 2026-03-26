<?php
// Utility script: generate a bcrypt hash for a given password
// Usage: hash.php?password=yourpassword
// Remove or restrict access to this file in production!

$password = $_GET['password'] ?? '';
if (empty($password)) {
    echo json_encode(['error' => 'No password provided. Use ?password=yourpassword']);
    exit();
}

$hash = password_hash($password, PASSWORD_DEFAULT);
echo json_encode(['password' => $password, 'hash' => $hash]);
?>