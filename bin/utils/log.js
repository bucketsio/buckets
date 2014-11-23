/**
 * Abstracting log into its own module allows for maximum flexibility. If the
 * future requires, due to desire or need, advances in the logging functionality
 * one need only to modify this file.
 */

// -- Dependencies -------------------------------------------------------------
var winston = require('winston');

/**
 * Winston has a cli mode that pretty prints to the console with colors. Let's
 * use it.
 */
winston.cli();

// -- Export -------------------------------------------------------------------
module.exports = winston; 

