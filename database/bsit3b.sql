-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 26, 2026 at 12:21 AM
-- Server version: 10.6.24-MariaDB-cll-lve
-- PHP Version: 8.3.30
-- NOTE: Orphaned empty-ID booking row has been removed from this reference dump.

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bsit3b`
--

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_bookings`
--

CREATE TABLE `pasabaybcd_bookings` (
  `id` varchar(50) NOT NULL COMMENT 'App-generated ID, e.g., BK-167...',
  `user_id` int(11) NOT NULL,
  `truck_id` int(11) NOT NULL,
  `driver_name` varchar(255) NOT NULL,
  `cargo_category` varchar(100) NOT NULL,
  `cargo_weight_kg` decimal(10,2) NOT NULL,
  `cargo_quantity` int(11) NOT NULL,
  `estimated_fee` decimal(10,2) NOT NULL,
  `cargo_photo_url` varchar(255) DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'pending' COMMENT 'pending, confirmed, in_transit, completed, cancelled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `pasabaybcd_bookings`
-- (orphaned empty-ID row removed)
--

INSERT INTO `pasabaybcd_bookings` (`id`, `user_id`, `truck_id`, `driver_name`, `cargo_category`, `cargo_weight_kg`, `cargo_quantity`, `estimated_fee`, `cargo_photo_url`, `status`, `created_at`, `completed_at`) VALUES
('BK-1773579690-2146', 1, 44, 'Ivan Lim', 'Produce', 15.00, 2, 143.00, 'http://ov3.238.mytemp.website/pasabaybcd/uploads/bookings/booking-1-1773579690.jpg', 'pending', '2026-03-15 13:01:30', NULL),
('BK-1773579701-8288', 1, 44, 'Ivan Lim', 'Produce', 15.00, 2, 143.00, 'http://ov3.238.mytemp.website/pasabaybcd/uploads/bookings/booking-1-1773579701.jpg', 'pending', '2026-03-15 13:01:41', NULL),
('BK-1773579711-7455', 1, 44, 'Ivan Lim', 'Produce', 15.00, 2, 143.00, 'http://ov3.238.mytemp.website/pasabaybcd/uploads/bookings/booking-1-1773579711.jpg', 'pending', '2026-03-15 13:01:51', NULL),
('BK-1773579726-5522', 1, 44, 'Ivan Lim', 'Produce', 15.00, 2, 143.00, 'http://ov3.238.mytemp.website/pasabaybcd/uploads/bookings/booking-1-1773579726.jpg', 'pending', '2026-03-15 13:02:06', NULL),
('BK-1773582204-6514', 1, 44, 'Ivan Lim', 'Produce', 15.00, 2, 143.00, 'http://ov3.238.mytemp.website/pasabaybcd/uploads/bookings/booking-1-1773582204.jpg', 'completed', '2026-03-15 13:43:24', '2026-03-15 14:35:03'),
('BK-1773889306-2902', 1, 42, 'Leo Ramos', 'Box', 10.00, 4, 104.00, 'http://ov3.238.mytemp.website/pasabaybcd/uploads/bookings/booking-1-1773889306.jpg', 'completed', '2026-03-19 03:01:46', '2026-03-19 03:02:31');

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_drivers`
--

CREATE TABLE `pasabaybcd_drivers` (
  `id` int(11) NOT NULL,
  `driver_name` varchar(255) NOT NULL,
  `rating` decimal(2,1) NOT NULL DEFAULT 5.0,
  `profile_photo_url` varchar(255) DEFAULT NULL,
  `is_vaccinated` tinyint(1) NOT NULL DEFAULT 0,
  `phone_number` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `pasabaybcd_drivers` (`id`, `driver_name`, `rating`, `profile_photo_url`, `is_vaccinated`, `phone_number`, `created_at`) VALUES
(1, 'Manong Juan', 4.7, NULL, 1, NULL, '2026-03-09 11:56:30'),
(2, 'Kuya Ben', 4.5, NULL, 0, NULL, '2026-03-09 11:56:30'),
(3, 'Lolo Bert', 4.3, NULL, 1, NULL, '2026-03-09 11:56:30'),
(4, 'Mang Kardo', 4.8, NULL, 1, NULL, '2026-03-09 11:56:30'),
(5, 'Kuya Romy', 4.6, NULL, 1, NULL, '2026-03-09 11:56:30'),
(6, 'Nong Pido', 4.4, NULL, 0, NULL, '2026-03-09 11:56:30'),
(7, 'Alfredo Mendoza', 4.8, NULL, 1, NULL, '2026-03-09 12:46:40'),
(8, 'Javier Santos', 4.4, NULL, 1, NULL, '2026-03-09 12:46:40'),
(9, 'Chris Lim', 4.6, NULL, 0, NULL, '2026-03-09 12:46:40'),
(10, 'Noel Garcia', 4.3, NULL, 1, NULL, '2026-03-09 12:46:40'),
(11, 'Pedro Vargas', 4.2, NULL, 1, NULL, '2026-03-09 12:46:40'),
(12, 'Ivan Mendoza', 4.8, NULL, 0, NULL, '2026-03-09 12:46:40'),
(13, 'Ben Yap', 4.7, NULL, 1, NULL, '2026-03-09 12:46:40'),
(14, 'Alex Gomez', 4.9, NULL, 1, NULL, '2026-03-09 12:46:40'),
(15, 'Andres Lim', 4.2, NULL, 0, NULL, '2026-03-09 12:46:40'),
(16, 'Mario Cruz', 4.4, NULL, 0, NULL, '2026-03-09 12:46:40'),
(17, 'Raul Yap', 4.5, NULL, 1, NULL, '2026-03-09 12:46:40'),
(18, 'Javier Garcia', 4.8, NULL, 1, NULL, '2026-03-09 12:46:40'),
(19, 'Carlos Gomez', 4.4, NULL, 1, NULL, '2026-03-09 12:46:40'),
(20, 'Alfredo Diaz', 4.7, NULL, 0, NULL, '2026-03-09 12:46:40'),
(21, 'Rico Yap', 4.8, NULL, 1, NULL, '2026-03-09 12:46:40'),
(22, 'Luis Perez', 4.3, NULL, 0, NULL, '2026-03-09 12:46:40'),
(23, 'Leo Garcia', 4.6, NULL, 1, NULL, '2026-03-09 12:46:40'),
(24, 'Jun Mendoza', 4.8, NULL, 0, NULL, '2026-03-09 12:46:40'),
(25, 'Ivan Yap', 4.6, NULL, 1, NULL, '2026-03-09 12:46:40'),
(26, 'Chris Perez', 4.3, NULL, 0, NULL, '2026-03-09 12:46:40'),
(27, 'Noel Garcia', 4.9, NULL, 1, NULL, '2026-03-09 12:46:40'),
(28, 'Ramon Lim', 4.8, NULL, 1, NULL, '2026-03-09 12:46:40'),
(29, 'Felipe Mendoza', 4.4, NULL, 0, NULL, '2026-03-09 12:46:40'),
(30, 'Arturo Santos', 4.6, NULL, 1, NULL, '2026-03-09 12:46:40'),
(31, 'Ben Cruz', 4.5, NULL, 1, NULL, '2026-03-09 12:46:40'),
(32, 'Ivan Gomez', 4.8, NULL, 0, NULL, '2026-03-09 12:46:40'),
(33, 'Ivan Perez', 4.6, NULL, 0, NULL, '2026-03-09 12:46:40'),
(34, 'Rico Garcia', 4.3, NULL, 1, NULL, '2026-03-09 12:46:40'),
(35, 'Diego Mendoza', 4.4, NULL, 1, NULL, '2026-03-09 12:46:40'),
(36, 'Andres Tan', 4.6, NULL, 1, NULL, '2026-03-09 12:46:40'),
(37, 'Javier Mendoza', 4.8, NULL, 0, NULL, '2026-03-09 12:46:40'),
(38, 'Chris Tan', 4.6, NULL, 0, NULL, '2026-03-09 12:46:40'),
(39, 'Emilio Santos', 4.4, NULL, 1, NULL, '2026-03-09 12:46:40'),
(40, 'Ramon Mendoza', 4.2, NULL, 0, NULL, '2026-03-09 12:46:40'),
(41, 'Ben Reyes', 4.7, NULL, 1, NULL, '2026-03-09 12:46:40'),
(42, 'Leo Ramos', 4.8, NULL, 1, NULL, '2026-03-09 12:46:40'),
(43, 'Noel Yap', 4.2, NULL, 0, NULL, '2026-03-09 12:46:40'),
(44, 'Ivan Lim', 4.8, NULL, 1, NULL, '2026-03-09 12:46:40'),
(45, 'Arturo Garcia', 4.3, NULL, 1, NULL, '2026-03-09 12:46:40'),
(46, 'Oscar Tan', 4.7, NULL, 0, NULL, '2026-03-09 12:46:40'),
(47, 'Jose Tan', 4.6, NULL, 1, NULL, '2026-03-09 12:46:40'),
(48, 'Rico Santos', 4.4, NULL, 1, NULL, '2026-03-09 12:46:40'),
(49, 'Felipe Ramos', 4.8, NULL, 0, NULL, '2026-03-09 12:46:40'),
(50, 'Javier Yap', 4.5, NULL, 1, NULL, '2026-03-09 12:46:40'),
(51, 'Ramon Perez', 4.8, NULL, 0, NULL, '2026-03-09 12:46:40'),
(52, 'Alex Santos', 4.3, NULL, 1, NULL, '2026-03-09 12:46:40'),
(53, 'Luis Yap', 4.6, NULL, 0, NULL, '2026-03-09 12:46:40'),
(54, 'Ben Vargas', 4.5, NULL, 1, NULL, '2026-03-09 12:46:40'),
(55, 'Rico Lim', 4.3, NULL, 1, NULL, '2026-03-09 12:46:40'),
(56, 'Ivan Tan', 4.5, NULL, 0, NULL, '2026-03-09 12:46:40');

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_images`
--

CREATE TABLE `pasabaybcd_images` (
  `id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_notifications`
--

CREATE TABLE `pasabaybcd_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` varchar(30) NOT NULL DEFAULT 'system',
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_payment`
--

CREATE TABLE `pasabaybcd_payment` (
  `transaction_id` varchar(50) NOT NULL,
  `amount` float DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp(),
  `booking_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_ratings`
--

CREATE TABLE `pasabaybcd_ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `booking_id` varchar(50) DEFAULT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `tags` text DEFAULT NULL,
  `review_text` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `driver_id` (`driver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_transactions`
--

CREATE TABLE `pasabaybcd_transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `booking_id` varchar(50) DEFAULT NULL COMMENT 'Link to a booking if it is a trip payment',
  `type` enum('top_up','trip_payment','withdrawal') NOT NULL,
  `amount` decimal(10,2) NOT NULL COMMENT 'Always a positive value',
  `label` varchar(255) NOT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `pasabaybcd_transactions` (`id`, `user_id`, `booking_id`, `type`, `amount`, `label`, `transaction_date`) VALUES
(1, 1, NULL, 'trip_payment', 150.00, 'Libertad Trip', '2024-01-14 17:00:00'),
(2, 1, NULL, 'trip_payment', 80.00, 'Burgos Trip', '2024-01-12 18:00:00'),
(3, 1, NULL, 'trip_payment', 120.00, 'Central Market Trip', '2024-01-10 16:30:00'),
(4, 1, NULL, 'trip_payment', 95.00, 'Tangub Trip', '2024-01-08 21:00:00'),
(5, 1, NULL, 'top_up', 500.00, 'Top Up via GCash', '2026-03-09 12:41:25'),
(6, 1, NULL, 'top_up', 100.00, 'Top Up via Maya', '2026-03-09 14:19:50'),
(7, 1, NULL, 'top_up', 200.00, 'Top Up via GCash', '2026-03-10 03:13:05'),
(8, 3, NULL, 'top_up', 500.00, 'Top Up via GCash', '2026-03-11 01:16:47'),
(9, 1, NULL, 'top_up', 1000.00, 'Top Up via Bank Transfer', '2026-03-17 03:27:09');

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_trip`
--

CREATE TABLE `pasabaybcd_trip` (
  `trip_id` varchar(50) NOT NULL,
  `destination` varchar(255) DEFAULT NULL,
  `start_location` varchar(255) DEFAULT NULL,
  `route_gps` text DEFAULT NULL,
  `driver_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_trucks`
--

CREATE TABLE `pasabaybcd_trucks` (
  `id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL COMMENT 'e.g., L300 VAN, MULTICAB',
  `plate_number` varchar(20) NOT NULL,
  `capacity_kg` decimal(10,2) NOT NULL,
  `capacity_cbm` decimal(10,2) NOT NULL,
  `base_price` decimal(10,2) NOT NULL,
  `current_route` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `depart_time` time DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'available' COMMENT 'available, on_trip, maintenance'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `pasabaybcd_trucks` (`id`, `driver_id`, `type`, `plate_number`, `capacity_kg`, `capacity_cbm`, `base_price`, `current_route`, `depart_time`, `status`) VALUES
(1, 1, 'L300 VAN', 'BCD-123', 200.00, 1.50, 150.00, 'Libertad -> Mansilingan', '14:30:00', 'available'),
(2, 2, 'MULTICAB', 'PAD-682', 100.00, 0.80, 80.00, 'Burgos -> Bata', '15:00:00', 'available'),
(3, 3, 'L300 VAN', 'BCD-445', 180.00, 1.20, 120.00, 'Central Market -> Tangub', '16:00:00', 'available'),
(4, 4, 'MULTICAB', 'BAK-111', 120.00, 1.00, 90.00, 'Libertad -> Alijis', '14:45:00', 'available'),
(5, 5, 'L300 VAN', 'CAR-555', 220.00, 1.60, 160.00, 'Burgos -> Estefania', '15:15:00', 'available'),
(6, 6, 'MULTICAB', 'XYZ-999', 150.00, 1.10, 110.00, 'Central Market -> Sum-ag', '16:30:00', 'available'),
(7, 7, 'L300 VAN', 'TMP-001', 204.00, 1.40, 172.00, 'Central Market -> Pahanocoy', '17:30:00', 'available'),
(8, 8, 'L300 VAN', 'TMP-002', 202.00, 1.80, 178.00, 'Libertad Market -> Taculing', '15:30:00', 'available'),
(9, 9, 'MULTICAB', 'TMP-003', 138.00, 1.10, 101.00, 'Central Market -> Bata', '14:00:00', 'available'),
(10, 10, 'L300 VAN', 'TMP-004', 241.00, 1.70, 158.00, 'Libertad Market -> Taculing', '15:15:00', 'available'),
(11, 11, 'MULTICAB', 'TMP-005', 132.00, 1.10, 111.00, 'Burgos Market -> Pahanocoy', '13:00:00', 'available'),
(12, 12, 'MULTICAB', 'TMP-006', 133.00, 1.20, 119.00, 'Burgos Market -> Taculing', '17:30:00', 'available'),
(13, 13, 'L300 VAN', 'TMP-007', 221.00, 1.50, 174.00, 'Burgos Market -> Sum-ag', '16:00:00', 'available'),
(14, 14, 'L300 VAN', 'TMP-008', 214.00, 1.30, 142.00, 'Central Market -> Pahanocoy', '13:45:00', 'available'),
(15, 15, 'MULTICAB', 'TMP-009', 148.00, 1.00, 111.00, 'Libertad Market -> Taculing', '13:15:00', 'available'),
(16, 16, 'MULTICAB', 'TMP-010', 108.00, 0.90, 118.00, 'Central Market -> Handumanan', '16:00:00', 'available'),
(17, 17, 'MULTICAB', 'TMP-011', 128.00, 1.20, 108.00, 'Libertad Market -> Villamonte', '15:30:00', 'available'),
(18, 18, 'L300 VAN', 'TMP-012', 211.00, 1.40, 169.00, 'Central Market -> Granada', '14:15:00', 'available'),
(19, 19, 'MULTICAB', 'TMP-013', 143.00, 1.20, 106.00, 'Libertad Market -> Pahanocoy', '14:30:00', 'available'),
(20, 20, 'L300 VAN', 'TMP-014', 205.00, 1.30, 150.00, 'Central Market -> Alijis', '13:45:00', 'available'),
(21, 21, 'L300 VAN', 'TMP-015', 241.00, 1.70, 141.00, 'Burgos Market -> Taculing', '17:45:00', 'available'),
(22, 22, 'MULTICAB', 'TMP-016', 110.00, 1.00, 116.00, 'Burgos Market -> Bata', '14:30:00', 'available'),
(23, 23, 'L300 VAN', 'TMP-017', 223.00, 1.60, 144.00, 'Libertad Market -> Estefania', '17:00:00', 'available'),
(24, 24, 'L300 VAN', 'TMP-018', 203.00, 1.60, 164.00, 'Libertad Market -> Taculing', '16:00:00', 'available'),
(25, 25, 'MULTICAB', 'TMP-019', 120.00, 1.00, 110.00, 'Central Market -> Pahanocoy', '13:45:00', 'available'),
(26, 26, 'L300 VAN', 'TMP-020', 211.00, 1.20, 168.00, 'Burgos Market -> Handumanan', '16:45:00', 'available'),
(27, 27, 'L300 VAN', 'TMP-021', 223.00, 1.70, 141.00, 'Libertad Market -> Pahanocoy', '15:15:00', 'available'),
(28, 28, 'L300 VAN', 'TMP-022', 234.00, 1.60, 162.00, 'Libertad Market -> Bata', '15:30:00', 'available'),
(29, 29, 'MULTICAB', 'TMP-023', 141.00, 1.10, 111.00, 'Libertad Market -> Villamonte', '17:00:00', 'available'),
(30, 30, 'L300 VAN', 'TMP-024', 243.00, 1.30, 141.00, 'Libertad Market -> Singcang-Airport', '13:30:00', 'available'),
(31, 31, 'MULTICAB', 'TMP-025', 133.00, 1.00, 118.00, 'Central Market -> Taculing', '16:45:00', 'available'),
(32, 32, 'L300 VAN', 'TMP-026', 221.00, 1.60, 163.00, 'Central Market -> Pahanocoy', '14:45:00', 'available'),
(33, 33, 'MULTICAB', 'TMP-027', 123.00, 1.10, 88.00, 'Burgos Market -> Pahanocoy', '13:15:00', 'available'),
(34, 34, 'MULTICAB', 'TMP-028', 148.00, 1.10, 107.00, 'Central Market -> Villamonte', '13:15:00', 'available'),
(35, 35, 'MULTICAB', 'TMP-029', 141.00, 1.00, 114.00, 'Central Market -> Alijis', '13:15:00', 'available'),
(36, 36, 'L300 VAN', 'TMP-030', 206.00, 1.70, 178.00, 'Libertad Market -> Taculing', '17:45:00', 'available'),
(37, 37, 'MULTICAB', 'TMP-031', 128.00, 1.10, 111.00, 'Libertad Market -> Bata', '17:30:00', 'available'),
(38, 38, 'L300 VAN', 'TMP-032', 231.00, 1.60, 148.00, 'Libertad Market -> Bata', '16:15:00', 'available'),
(39, 39, 'L300 VAN', 'TMP-033', 248.00, 1.40, 143.00, 'Burgos Market -> Pahanocoy', '16:00:00', 'available'),
(40, 40, 'L300 VAN', 'TMP-034', 215.00, 1.70, 143.00, 'Libertad Market -> Pahanocoy', '14:30:00', 'available'),
(41, 41, 'MULTICAB', 'TMP-035', 111.00, 1.00, 118.00, 'Libertad Market -> Mansilingan', '14:00:00', 'available'),
(42, 42, 'MULTICAB', 'TMP-036', 149.00, 1.10, 104.00, 'Libertad Market -> Villamonte', '16:00:00', 'available'),
(43, 43, 'MULTICAB', 'TMP-037', 121.00, 1.10, 102.00, 'Libertad Market -> Pahanocoy', '15:15:00', 'available'),
(44, 44, 'L300 VAN', 'TMP-038', 218.00, 1.70, 143.00, 'Libertad Market -> Handumanan', '17:15:00', 'available'),
(45, 45, 'L300 VAN', 'TMP-039', 241.00, 1.30, 178.00, 'Libertad Market -> Villamonte', '15:30:00', 'available'),
(46, 46, 'MULTICAB', 'TMP-040', 148.00, 1.10, 93.00, 'Libertad Market -> Villamonte', '13:00:00', 'available'),
(47, 47, 'MULTICAB', 'TMP-041', 121.00, 1.10, 105.00, 'Libertad Market -> Pahanocoy', '17:30:00', 'available'),
(48, 48, 'MULTICAB', 'TMP-042', 125.00, 0.90, 109.00, 'Burgos Market -> Villamonte', '17:30:00', 'available'),
(49, 49, 'L300 VAN', 'TMP-043', 228.00, 1.70, 142.00, 'Burgos Market -> Pahanocoy', '17:30:00', 'available'),
(50, 50, 'L300 VAN', 'TMP-044', 249.00, 1.30, 160.00, 'Central Market -> Bata', '14:45:00', 'available'),
(51, 51, 'MULTICAB', 'TMP-045', 141.00, 1.10, 119.00, 'Libertad Market -> Villamonte', '15:00:00', 'available'),
(52, 52, 'L300 VAN', 'TMP-046', 241.00, 1.30, 155.00, 'Central Market -> Tangub', '15:15:00', 'available'),
(53, 53, 'L300 VAN', 'TMP-047', 234.00, 1.40, 161.00, 'Central Market -> Alijis', '13:00:00', 'available'),
(54, 54, 'MULTICAB', 'TMP-048', 101.00, 1.10, 103.00, 'Central Market -> Villamonte', '17:00:00', 'available'),
(55, 55, 'L300 VAN', 'TMP-049', 248.00, 1.70, 175.00, 'Burgos Market -> Taculing', '16:45:00', 'available'),
(56, 56, 'MULTICAB', 'TMP-050', 139.00, 1.20, 91.00, 'Central Market -> Pahanocoy', '13:30:00', 'available');

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_users`
-- NOTE: role column added via migration.sql
--

CREATE TABLE `pasabaybcd_users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL COMMENT 'Should store a hashed password',
  `full_name` varchar(255) DEFAULT NULL,
  `business_permit_number` varchar(255) DEFAULT NULL,
  `id_photo_url` varchar(255) DEFAULT NULL,
  `merchant_name` varchar(255) NOT NULL,
  `market_location` varchar(255) DEFAULT NULL,
  `profile_photo_url` varchar(255) DEFAULT NULL,
  `is_kyc_verified` tinyint(1) NOT NULL DEFAULT 0,
  `wallet_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `role` varchar(20) NOT NULL DEFAULT 'passenger',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `pasabaybcd_users` (`id`, `email`, `password_hash`, `full_name`, `business_permit_number`, `id_photo_url`, `merchant_name`, `market_location`, `profile_photo_url`, `is_kyc_verified`, `wallet_balance`, `role`, `created_at`) VALUES
(1, 'aling.nena@email.com', '$2y$10$VCojEQ7hLcK/PBUHfItOHuPfURXTy8DryC4kOocvFomuyw6f5u/V6', 'Hey', '928282882', 'http://ov3.238.mytemp.website/pasabaybcd/uploads/kyc/kyc-1-1773112408.jpg', 'Aling Nena\'s Stall', 'Libertad Market, Aisle 9', NULL, 1, 2260.00, 'passenger', '2026-03-09 11:56:30'),
(2, 'john@email.com', '$2y$10$OoqKOu7kyozKtLTDvPUkM.iRqJxUR88NRATAZbAk3da8fR87rLE.G', 'John', NULL, NULL, '', NULL, NULL, 0, 0.00, 'passenger', '2026-03-11 01:13:20'),
(3, 'fish@gmail.com', '$2y$10$IdpkQGkqoUz7A3G0wok9TesxAK1REugGlasWCH4.6mfJIV1sqAjZ6', 'Fish', NULL, NULL, '', NULL, NULL, 0, 500.00, 'passenger', '2026-03-11 01:13:52');

-- --------------------------------------------------------

--
-- Table structure for table `pasabaybcd_vehicle`
--

CREATE TABLE `pasabaybcd_vehicle` (
  `plate_number` varchar(20) NOT NULL,
  `model` varchar(50) DEFAULT NULL,
  `capacity` float DEFAULT NULL,
  `owner_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes
--

ALTER TABLE `pasabaybcd_bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `truck_id` (`truck_id`);

ALTER TABLE `pasabaybcd_drivers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone_number` (`phone_number`);

ALTER TABLE `pasabaybcd_images`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `pasabaybcd_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `pasabaybcd_payment`
  ADD PRIMARY KEY (`transaction_id`);

ALTER TABLE `pasabaybcd_ratings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `driver_id` (`driver_id`);

ALTER TABLE `pasabaybcd_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `booking_id` (`booking_id`);

ALTER TABLE `pasabaybcd_trip`
  ADD PRIMARY KEY (`trip_id`);

ALTER TABLE `pasabaybcd_trucks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `plate_number` (`plate_number`),
  ADD KEY `driver_id` (`driver_id`);

ALTER TABLE `pasabaybcd_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

ALTER TABLE `pasabaybcd_vehicle`
  ADD PRIMARY KEY (`plate_number`);

--
-- AUTO_INCREMENT
--

ALTER TABLE `pasabaybcd_drivers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

ALTER TABLE `pasabaybcd_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `pasabaybcd_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

ALTER TABLE `pasabaybcd_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `pasabaybcd_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

ALTER TABLE `pasabaybcd_trucks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

ALTER TABLE `pasabaybcd_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints
--

ALTER TABLE `pasabaybcd_bookings`
  ADD CONSTRAINT `pasabaybcd_bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `pasabaybcd_users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pasabaybcd_bookings_ibfk_2` FOREIGN KEY (`truck_id`) REFERENCES `pasabaybcd_trucks` (`id`) ON DELETE CASCADE;

ALTER TABLE `pasabaybcd_transactions`
  ADD CONSTRAINT `pasabaybcd_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `pasabaybcd_users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pasabaybcd_transactions_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `pasabaybcd_bookings` (`id`) ON DELETE SET NULL;

ALTER TABLE `pasabaybcd_trucks`
  ADD CONSTRAINT `pasabaybcd_trucks_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `pasabaybcd_drivers` (`id`) ON DELETE CASCADE;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
