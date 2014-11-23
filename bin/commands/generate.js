var log = require('../utils/log');
require('shelljs/global');
var SKELETON_URL = 'https://github.com/bucketsio/skeleton.git';

/**
 * Generate a Buckets project with a skeleton.
 *
 * @param {string} name - Where to create the skeleton.
 */
module.exports = function(name) {

  /**
   * Make sure git is installed.
   */
  if (!which('git')) {
    log.warn('git is required to generate a buckets Skeleton.');
    exit(1);
  }

  /**
   * Clone the skeleton repo.
   */
  if (exec('git clone ' + SKELETON_URL + ' ' + name).code !== 0) {
    log.error('Failed to create Buckets skeleton.');
    exit(1);
  }

  log.info('Project', name, 'created using Buckets Skeleton.');
  exit(0);

};
