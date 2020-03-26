-- phpMyAdmin SQL Dump
-- version 4.6.6
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 24, 2020 at 05:12 PM
-- Server version: 5.7.17-log
-- PHP Version: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `apocalypse`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `account_sql` int(11) NOT NULL,
  `account_password` varchar(129) NOT NULL DEFAULT 'NULL',
  `account_name` varchar(24) NOT NULL DEFAULT 'NULL',
  `account_availableslots` int(11) NOT NULL DEFAULT '3',
  `account_activeslots` int(11) NOT NULL DEFAULT '0',
  `account_staff` int(11) NOT NULL DEFAULT '0',
  `settings_pm` int(11) NOT NULL DEFAULT '1',
  `settings_ooc` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE `characters` (
  `char_sql` int(11) NOT NULL,
  `char_accountsql` int(11) NOT NULL DEFAULT '-1',
  `char_name` varchar(24) NOT NULL DEFAULT 'NULL',
  `char_posx` float NOT NULL DEFAULT '0',
  `char_posy` float NOT NULL DEFAULT '0',
  `char_posz` float NOT NULL DEFAULT '0',
  `char_posa` float NOT NULL DEFAULT '0',
  `char_vw` int(8) NOT NULL,
  `char_int` int(3) NOT NULL,
  `char_gender` int(11) NOT NULL DEFAULT '0',
  `char_age` int(11) NOT NULL DEFAULT '18',
  `char_configured` int(11) NOT NULL DEFAULT '0',
  `char_job` int(11) NOT NULL DEFAULT '0',
  `char_backpack` int(11) NOT NULL DEFAULT '0',
  `char_carry` float NOT NULL DEFAULT '0',
  `talent_mechanic` int(11) NOT NULL DEFAULT '0',
  `talent_fishing` int(11) NOT NULL DEFAULT '0',
  `talent_aim` int(11) NOT NULL DEFAULT '0',
  `talent_crafting` int(11) NOT NULL DEFAULT '0',
  `talent_firstaid` int(11) NOT NULL DEFAULT '0',
  `talent_cooking` int(11) NOT NULL DEFAULT '0',
  `char_level` int(3) NOT NULL DEFAULT '1',
  `char_exp` int(6) NOT NULL,
  `char_paydaytime` int(2) NOT NULL,
  `char_talentpoint` int(5) NOT NULL,
  `char_weapons` varchar(20) NOT NULL DEFAULT '0|0|0|0|0',
  `char_ammo` varchar(35) NOT NULL DEFAULT '0|0|0|0|0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dropped_items`
--

CREATE TABLE `dropped_items` (
  `ditem_id` int(12) NOT NULL,
  `ditem_x` float NOT NULL,
  `ditem_y` float NOT NULL,
  `ditem_z` float NOT NULL,
  `ditem_int` int(3) NOT NULL,
  `ditem_vw` int(7) NOT NULL,
  `ditem_item` int(2) NOT NULL,
  `ditem_amount` int(5) NOT NULL,
  `ditem_owned` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin5;

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `inv_id` int(11) NOT NULL,
  `inv_sql` int(11) NOT NULL DEFAULT '-1',
  `inv_item` int(11) NOT NULL DEFAULT '0',
  `inv_amount` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `lands`
--

CREATE TABLE `lands` (
  `land_id` int(11) NOT NULL,
  `land_x` float NOT NULL DEFAULT '0',
  `land_y` float NOT NULL DEFAULT '0',
  `land_z` float NOT NULL DEFAULT '0',
  `land_range` float NOT NULL DEFAULT '0',
  `land_maxseed` int(11) NOT NULL DEFAULT '0',
  `land_plantseed` int(11) NOT NULL DEFAULT '0',
  `land_plenty` int(11) NOT NULL DEFAULT '0',
  `land_group` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `lootplaces`
--

CREATE TABLE `lootplaces` (
  `lp_id` int(11) NOT NULL DEFAULT '-1',
  `lp_x` float NOT NULL DEFAULT '0',
  `lp_y` float NOT NULL DEFAULT '0',
  `lp_z` float NOT NULL DEFAULT '0',
  `lp_int` int(11) NOT NULL DEFAULT '0',
  `lp_vw` int(11) NOT NULL DEFAULT '0',
  `lp_inx` float NOT NULL DEFAULT '0',
  `lp_iny` float NOT NULL DEFAULT '0',
  `lp_inz` float NOT NULL DEFAULT '0',
  `lp_inint` int(11) NOT NULL DEFAULT '0',
  `lp_invw` int(11) NOT NULL DEFAULT '0',
  `lp_type` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `npcs`
--

CREATE TABLE `npcs` (
  `npc_id` int(11) NOT NULL,
  `npc_skin` int(11) NOT NULL,
  `npc_health` float NOT NULL,
  `npc_armour` float NOT NULL,
  `npc_damage` int(11) NOT NULL,
  `npc_walk_speed` int(11) NOT NULL,
  `npc_bite` int(11) NOT NULL,
  `npc_herd_id` int(11) NOT NULL,
  `npc_x` float NOT NULL,
  `npc_y` float NOT NULL,
  `npc_z` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `npcs_herds`
--

CREATE TABLE `npcs_herds` (
  `herd_id` int(11) NOT NULL,
  `herd_name` varchar(90) NOT NULL,
  `herd_created_date` int(11) NOT NULL,
  `herd_created_by` varchar(32) NOT NULL,
  `herd_next_point_id` int(11) NOT NULL,
  `herd_next_x` float NOT NULL,
  `herd_next_y` float NOT NULL,
  `herd_next_z` float NOT NULL,
  `herd_mode` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `npcs_herds_points`
--

CREATE TABLE `npcs_herds_points` (
  `point_id` int(11) NOT NULL,
  `point_x` float NOT NULL,
  `point_y` float NOT NULL,
  `point_z` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `safes`
--

CREATE TABLE `safes` (
  `safe_id` int(12) NOT NULL,
  `safe_owner` int(12) NOT NULL DEFAULT '-1',
  `safe_lock` int(1) NOT NULL,
  `safe_x` float NOT NULL,
  `safe_y` float NOT NULL,
  `safe_z` float NOT NULL,
  `safe_interior` int(3) NOT NULL,
  `safe_world` int(8) NOT NULL,
  `safe_password` varchar(30) NOT NULL,
  `safe_items` varchar(50) NOT NULL DEFAULT '-1|-1|-1|-1|-1|-1|-1|-1|-1|-1',
  `safe_amounts` varchar(100) NOT NULL DEFAULT '0|0|0|0|0|0|0|0|0|0'
) ENGINE=InnoDB DEFAULT CHARSET=latin5;

-- --------------------------------------------------------

--
-- Table structure for table `seeds`
--

CREATE TABLE `seeds` (
  `seed_id` int(11) NOT NULL,
  `seed_x` float NOT NULL DEFAULT '0',
  `seed_y` float NOT NULL DEFAULT '0',
  `seed_z` float NOT NULL DEFAULT '0',
  `seed_growth` int(11) NOT NULL DEFAULT '0',
  `seed_amount` int(11) NOT NULL DEFAULT '0',
  `seed_landid` int(11) NOT NULL DEFAULT '-1',
  `seed_type` int(11) NOT NULL DEFAULT '-1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tables`
--

CREATE TABLE `tables` (
  `table_id` int(11) NOT NULL,
  `table_x` float NOT NULL DEFAULT '0',
  `table_y` float NOT NULL DEFAULT '0',
  `table_z` float NOT NULL DEFAULT '0',
  `table_int` int(11) NOT NULL DEFAULT '0',
  `table_vw` int(11) NOT NULL DEFAULT '0',
  `table_object` int(11) NOT NULL DEFAULT '2115',
  `table_type` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tents`
--

CREATE TABLE `tents` (
  `tent_id` int(11) NOT NULL,
  `tent_x` float NOT NULL DEFAULT '0',
  `tent_y` float NOT NULL DEFAULT '0',
  `tent_z` float NOT NULL DEFAULT '0',
  `tent_rx` float NOT NULL DEFAULT '0',
  `tent_ry` float NOT NULL DEFAULT '0',
  `tent_rz` float NOT NULL DEFAULT '0',
  `tent_int` int(11) NOT NULL DEFAULT '0',
  `tent_vw` int(11) NOT NULL DEFAULT '0',
  `tent_inx` float NOT NULL DEFAULT '0',
  `tent_iny` float NOT NULL DEFAULT '0',
  `tent_inz` float NOT NULL DEFAULT '0',
  `tent_inint` int(11) NOT NULL DEFAULT '0',
  `tent_invw` int(11) NOT NULL DEFAULT '0',
  `tent_lock` int(11) NOT NULL DEFAULT '0',
  `tent_owner` int(11) NOT NULL DEFAULT '-1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `weaponsettings`
--

CREATE TABLE `weaponsettings` (
  `Owner` int(24) NOT NULL,
  `WeaponID` tinyint(4) NOT NULL,
  `PosX` float DEFAULT '-0.116',
  `PosY` float DEFAULT '0.189',
  `PosZ` float DEFAULT '0.088',
  `RotX` float DEFAULT '0',
  `RotY` float DEFAULT '44.5',
  `RotZ` float DEFAULT '0',
  `Bone` tinyint(4) NOT NULL DEFAULT '1',
  `Hidden` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`account_sql`);

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`char_sql`);

--
-- Indexes for table `dropped_items`
--
ALTER TABLE `dropped_items`
  ADD PRIMARY KEY (`ditem_id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`inv_id`);

--
-- Indexes for table `lands`
--
ALTER TABLE `lands`
  ADD UNIQUE KEY `land_id` (`land_id`);

--
-- Indexes for table `lootplaces`
--
ALTER TABLE `lootplaces`
  ADD UNIQUE KEY `lp_id` (`lp_id`);

--
-- Indexes for table `npcs`
--
ALTER TABLE `npcs`
  ADD PRIMARY KEY (`npc_id`);

--
-- Indexes for table `npcs_herds`
--
ALTER TABLE `npcs_herds`
  ADD PRIMARY KEY (`herd_id`);

--
-- Indexes for table `npcs_herds_points`
--
ALTER TABLE `npcs_herds_points`
  ADD PRIMARY KEY (`point_id`);

--
-- Indexes for table `safes`
--
ALTER TABLE `safes`
  ADD PRIMARY KEY (`safe_id`);

--
-- Indexes for table `seeds`
--
ALTER TABLE `seeds`
  ADD UNIQUE KEY `seed_id` (`seed_id`);

--
-- Indexes for table `tables`
--
ALTER TABLE `tables`
  ADD PRIMARY KEY (`table_id`);

--
-- Indexes for table `tents`
--
ALTER TABLE `tents`
  ADD UNIQUE KEY `tent_id` (`tent_id`);

--
-- Indexes for table `weaponsettings`
--
ALTER TABLE `weaponsettings`
  ADD UNIQUE KEY `weapon` (`Owner`,`WeaponID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `account_sql` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
  MODIFY `char_sql` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `dropped_items`
--
ALTER TABLE `dropped_items`
  MODIFY `ditem_id` int(12) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `inv_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `npcs`
--
ALTER TABLE `npcs`
  MODIFY `npc_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `npcs_herds`
--
ALTER TABLE `npcs_herds`
  MODIFY `herd_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `npcs_herds_points`
--
ALTER TABLE `npcs_herds_points`
  MODIFY `point_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `safes`
--
ALTER TABLE `safes`
  MODIFY `safe_id` int(12) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `tables`
--
ALTER TABLE `tables`
  MODIFY `table_id` int(11) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
