-- ============================================================
-- PasabayBCD3 Database Migration
-- Adds missing role column, ratings + notifications tables,
-- removes orphaned empty-ID booking row, and seeds notifications
-- safely with INSERT IGNORE.
-- ============================================================

-- 1) Add role column to users table
ALTER TABLE `pasabaybcd_users`
  ADD COLUMN IF NOT EXISTS `role` VARCHAR(20) NOT NULL DEFAULT 'passenger';

-- 2) Remove orphaned bad booking row with empty primary key
DELETE FROM `pasabaybcd_bookings`
WHERE `id` = '';

-- 3) Create ratings table
CREATE TABLE IF NOT EXISTS `pasabaybcd_ratings` (
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

-- 4) Create notifications table
CREATE TABLE IF NOT EXISTS `pasabaybcd_notifications` (
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

-- 5) Seed sample notifications (INSERT IGNORE to avoid duplicates on re-run)
INSERT IGNORE INTO `pasabaybcd_notifications` (`id`, `user_id`, `type`, `title`, `body`) VALUES
(1, 1, 'system', 'Welcome to PasabayBCD!', 'Thank you for joining PasabayBCD. Start by booking your first shared delivery.'),
(2, 1, 'promo', 'Weekend Promo!', 'Get 15% off your next booking this Saturday & Sunday.'),
(3, 1, 'wallet', 'Top-Up Successful', 'Your wallet has been topped up with ₱500 via GCash.'),
(4, 1, 'system', 'App Update Available', 'PasabayBCD v1.1 is now available. Update for new features!');
