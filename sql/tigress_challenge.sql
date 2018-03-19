-- MySQL dump 10.13  Distrib 5.7.21, for Linux (x86_64)
--
-- Host: localhost    Database: tigress_challenge
-- ------------------------------------------------------
-- Server version	5.7.21-0ubuntu0.16.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `tigress_challenge_competition`
--
CREATE DATABASE IF NOT EXISTS `tigress_challenge_competition` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `tigress_challenge_competition`;

--
-- Table structure for table `auto_grade_args`
--

DROP TABLE IF EXISTS `auto_grade_args`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_grade_args` (
  `challenge_name` varchar(100) NOT NULL,
  `test_number` int(11) NOT NULL,
  `arg_order` int(11) NOT NULL,
  `arg_type` varchar(25) DEFAULT NULL,
  `arg_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`arg_order`,`test_number`,`challenge_name`),
  KEY `challenge_name` (`challenge_name`),
  KEY `auto_grade_args_default_ibfk_1` (`challenge_name`,`test_number`),
  CONSTRAINT `auto_grade_args_ibfk_1` FOREIGN KEY (`challenge_name`, `test_number`) REFERENCES `auto_grade_tests` (`challenge_name`, `test_number`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_grade_args_default`
--

DROP TABLE IF EXISTS `auto_grade_args_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_grade_args_default` (
  `challenge_name` varchar(100) NOT NULL,
  `test_number` int(11) NOT NULL,
  `arg_order` int(11) NOT NULL,
  `arg_type` varchar(25) DEFAULT NULL,
  `arg_value` varchar(200) DEFAULT NULL,
  `administrator` varchar(50) NOT NULL,
  PRIMARY KEY (`arg_order`,`test_number`,`challenge_name`,`administrator`) USING BTREE,
  KEY `challenge_name` (`challenge_name`),
  KEY `auto_grade_args_default_ibfk_1` (`challenge_name`,`test_number`),
  KEY `challenge_name_2` (`challenge_name`,`test_number`,`administrator`),
  CONSTRAINT `auto_grade_args_default_ibfk_1` FOREIGN KEY (`challenge_name`, `test_number`, `administrator`) REFERENCES `auto_grade_tests_default` (`challenge_name`, `test_number`, `administrator`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_grade_input`
--

DROP TABLE IF EXISTS `auto_grade_input`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_grade_input` (
  `challenge_name` varchar(100) NOT NULL,
  `test_number` int(11) NOT NULL,
  `input_order` int(11) NOT NULL,
  `input_string` text NOT NULL,
  PRIMARY KEY (`challenge_name`,`test_number`,`input_order`) USING BTREE,
  CONSTRAINT `auto_grade_input_ibfk_1` FOREIGN KEY (`challenge_name`, `test_number`) REFERENCES `auto_grade_tests` (`challenge_name`, `test_number`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_grade_input_default`
--

DROP TABLE IF EXISTS `auto_grade_input_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_grade_input_default` (
  `challenge_name` varchar(100) NOT NULL,
  `test_number` int(11) NOT NULL,
  `input_order` int(11) NOT NULL,
  `input_string` text NOT NULL,
  PRIMARY KEY (`challenge_name`,`test_number`,`input_order`) USING BTREE,
  CONSTRAINT `auto_grade_input_default_ibfk_1` FOREIGN KEY (`challenge_name`, `test_number`) REFERENCES `auto_grade_tests_default` (`challenge_name`, `test_number`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_grade_performance`
--

DROP TABLE IF EXISTS `auto_grade_performance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_grade_performance` (
  `challenge_name` varchar(100) NOT NULL,
  `test_number` int(11) NOT NULL,
  `instruction` varchar(25) NOT NULL,
  `maxMult` int(11) NOT NULL,
  PRIMARY KEY (`challenge_name`,`test_number`,`instruction`) USING BTREE,
  CONSTRAINT `auto_grade_performance_ibfk_1` FOREIGN KEY (`challenge_name`, `test_number`) REFERENCES `auto_grade_tests` (`challenge_name`, `test_number`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_grade_tests`
--

DROP TABLE IF EXISTS `auto_grade_tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_grade_tests` (
  `challenge_name` varchar(100) NOT NULL,
  `test_number` int(11) NOT NULL,
  `num_iterations` int(11) NOT NULL,
  `performance_multiplier` double NOT NULL DEFAULT '2',
  PRIMARY KEY (`test_number`,`challenge_name`),
  KEY `challenge_name` (`challenge_name`),
  CONSTRAINT `auto_grade_tests_ibfk_1` FOREIGN KEY (`challenge_name`) REFERENCES `challenge` (`challenge_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_grade_tests_default`
--

DROP TABLE IF EXISTS `auto_grade_tests_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_grade_tests_default` (
  `challenge_name` varchar(100) NOT NULL,
  `test_number` int(11) NOT NULL,
  `num_iterations` int(11) NOT NULL,
  `performance_multiplier` double NOT NULL DEFAULT '2',
  `administrator` varchar(50) NOT NULL,
  PRIMARY KEY (`test_number`,`challenge_name`,`administrator`) USING BTREE,
  KEY `challenge_name` (`challenge_name`),
  KEY `auto_grade_tests_default_ibfk_1` (`challenge_name`,`administrator`),
  CONSTRAINT `auto_grade_tests_default_ibfk_1` FOREIGN KEY (`challenge_name`, `administrator`) REFERENCES `challenge_default` (`challenge_name`, `administrator`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge`
--

DROP TABLE IF EXISTS `challenge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge` (
  `challenge_name` varchar(100) NOT NULL,
  `admin_email` varchar(50) NOT NULL,
  `open_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `end_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `description` text NOT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'assignment',
  `auto_grade` tinyint(1) NOT NULL DEFAULT '0',
  `randomSeed` tinyint(1) NOT NULL DEFAULT '1',
  `seed` text,
  PRIMARY KEY (`challenge_name`),
  KEY `admin_email` (`admin_email`),
  CONSTRAINT `challenge_ibfk_1` FOREIGN KEY (`admin_email`) REFERENCES `user` (`email`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge_command`
--

DROP TABLE IF EXISTS `challenge_command`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge_command` (
  `command_order` int(11) NOT NULL,
  `commandName` text NOT NULL,
  `command` text NOT NULL,
  `challenge_name` varchar(100) NOT NULL,
  PRIMARY KEY (`command_order`,`challenge_name`),
  KEY `challenge_name` (`challenge_name`),
  CONSTRAINT `challenge_command_ibfk_1` FOREIGN KEY (`challenge_name`) REFERENCES `challenge` (`challenge_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge_command_default`
--

DROP TABLE IF EXISTS `challenge_command_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge_command_default` (
  `command_order` int(11) NOT NULL,
  `commandName` text NOT NULL,
  `command` text NOT NULL,
  `challenge_name` varchar(100) NOT NULL,
  `actionType` varchar(50) DEFAULT NULL,
  `administrator` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`command_order`,`challenge_name`,`administrator`) USING BTREE,
  KEY `challenge_name` (`challenge_name`),
  KEY `challenge_command_default_ibfk_1` (`challenge_name`,`administrator`),
  CONSTRAINT `challenge_command_default_ibfk_1` FOREIGN KEY (`challenge_name`, `administrator`) REFERENCES `challenge_default` (`challenge_name`, `administrator`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge_default`
--

DROP TABLE IF EXISTS `challenge_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge_default` (
  `challenge_name` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `extendedDescription` text,
  `administrator` varchar(50) NOT NULL DEFAULT '',
  `auto_grade` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`challenge_name`,`administrator`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge_evaluate_command`
--

DROP TABLE IF EXISTS `challenge_evaluate_command`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge_evaluate_command` (
  `command_order` int(11) NOT NULL,
  `commandName` text NOT NULL,
  `command` text NOT NULL,
  `challenge_name` varchar(100) NOT NULL,
  `random_args` int(11) NOT NULL DEFAULT '0',
  `input_output` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`command_order`,`challenge_name`),
  KEY `challenge_name` (`challenge_name`),
  CONSTRAINT `challenge_evaluate_command_ibfk_1` FOREIGN KEY (`challenge_name`) REFERENCES `challenge` (`challenge_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge_participant`
--

DROP TABLE IF EXISTS `challenge_participant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge_participant` (
  `challenge_name` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `code_generated` tinyint(4) NOT NULL DEFAULT '0',
  `codeGeneratedTime` timestamp(4) NOT NULL DEFAULT CURRENT_TIMESTAMP(4) ON UPDATE CURRENT_TIMESTAMP(4),
  `grade` double DEFAULT NULL,
  `originalFile` longblob,
  `gradingFile` longblob,
  `obfuscatedFile` longblob,
  `submittedFile` longblob,
  `submittedWrittenFile` longblob,
  `submissionTime` timestamp NULL DEFAULT NULL,
  `participantSeed` text,
  PRIMARY KEY (`challenge_name`,`email`),
  KEY `email` (`email`),
  CONSTRAINT `challenge_participant_ibfk_1` FOREIGN KEY (`challenge_name`) REFERENCES `challenge` (`challenge_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `challenge_participant_ibfk_2` FOREIGN KEY (`email`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `challenge_participant_ibfk_3` FOREIGN KEY (`challenge_name`) REFERENCES `challenge` (`challenge_name`),
  CONSTRAINT `challenge_participant_ibfk_4` FOREIGN KEY (`challenge_name`) REFERENCES `challenge` (`challenge_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `challenge_participant_ibfk_5` FOREIGN KEY (`email`) REFERENCES `user` (`email`),
  CONSTRAINT `challenge_participant_ibfk_6` FOREIGN KEY (`email`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge_participant_grades`
--

DROP TABLE IF EXISTS `challenge_participant_grades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge_participant_grades` (
  `challenge_name` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `test_number` int(11) NOT NULL,
  `iterations_passed` int(11) NOT NULL,
  `correct` tinyint(1) NOT NULL,
  `performance` tinyint(1) NOT NULL,
  `in_progress` tinyint(1) NOT NULL,
  PRIMARY KEY (`challenge_name`,`email`,`test_number`),
  KEY `challenge_name` (`challenge_name`,`test_number`),
  CONSTRAINT `challenge_participant_grades_ibfk_1` FOREIGN KEY (`challenge_name`, `email`) REFERENCES `challenge_participant` (`challenge_name`, `email`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `challenge_participant_grades_ibfk_2` FOREIGN KEY (`challenge_name`, `test_number`) REFERENCES `auto_grade_tests` (`challenge_name`, `test_number`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `institution`
--

DROP TABLE IF EXISTS `institution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `institution` (
  `institutionName` varchar(100) NOT NULL,
  PRIMARY KEY (`institutionName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `email` varchar(50) NOT NULL,
  `role` varchar(50) NOT NULL,
  `administrator` varchar(50) DEFAULT NULL,
  `course` varchar(50) NOT NULL,
  PRIMARY KEY (`email`,`role`),
  CONSTRAINT `role_ibfk_1` FOREIGN KEY (`email`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `username` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(128) NOT NULL,
  `fName` varchar(50) NOT NULL,
  `mName` varchar(50) NOT NULL,
  `lName` varchar(50) NOT NULL,
  `lastLogon` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `currentVisit` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `previousVisit` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `loginIP` varchar(100) NOT NULL,
  `salt` varchar(120) DEFAULT NULL,
  `changeIP` varchar(100) DEFAULT NULL,
  `changeURL` text,
  `changeUserEmail` varchar(50) DEFAULT NULL,
  `displayRealName` tinyint(1) NOT NULL DEFAULT '0',
  `passwordPlaintext` text NOT NULL,
  `downloadedDataCollection` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`email`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_request`
--

DROP TABLE IF EXISTS `user_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_request` (
  `username` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(128) NOT NULL,
  `fName` varchar(50) NOT NULL,
  `mName` varchar(50) NOT NULL,
  `lName` varchar(50) NOT NULL,
  `lastLogon` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `currentVisit` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `previousVisit` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `loginIP` varchar(100) NOT NULL,
  `salt` varchar(120) DEFAULT NULL,
  `changeIP` varchar(100) DEFAULT NULL,
  `changeURL` text,
  `changeUserEmail` varchar(50) DEFAULT NULL,
  `displayRealName` tinyint(1) NOT NULL DEFAULT '0',
  `passwordPlaintext` text NOT NULL,
  `message` text NOT NULL,
  `role` varchar(50) NOT NULL,
  PRIMARY KEY (`email`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-03-15 14:58:29
