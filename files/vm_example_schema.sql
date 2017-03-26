-- MySQL Script generated by MySQL Workbench
-- 03/26/17 09:40:28
-- Model: New Model    Version: 1.0
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema vm_example_schema
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `vm_example_schema` ;
CREATE SCHEMA IF NOT EXISTS `vm_example_schema` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
SHOW WARNINGS;
USE `vm_example_schema` ;

-- -----------------------------------------------------
-- Table `vm_example_schema`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vm_example_schema`.`user` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `vm_example_schema`.`user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

SHOW WARNINGS;
CREATE UNIQUE INDEX `name_UNIQUE` ON `vm_example_schema`.`user` (`name` ASC);

SHOW WARNINGS;
CREATE UNIQUE INDEX `email_UNIQUE` ON `vm_example_schema`.`user` (`email` ASC);

SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
