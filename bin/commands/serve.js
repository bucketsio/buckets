var log = require('../utils/log');
var _ = require('lodash');

/**
 * Serve the local theme directory directly.
 *
 * @param {num} port - The port to use. Defaults to 3000.
 */
module.exports = function(port) {

  /**
   * Coerce port to a number and check that it is a number.
   */
  port = Number(port);
  if (!_.isNumber(port) || _.isNaN(port)) {
    port = 3000;
  }

  /**
   * Currently unimplemented. :(
   */
  log.warn('Not implemented yet. :(');
};
