// ========================================================================
// Centralized Logging Utility
// ========================================================================

const LOG_LEVELS = {
  DEBUG: 'DEBUG',
  INFO: 'INFO',
  WARN: 'WARN',
  ERROR: 'ERROR'
};

class Logger {
  constructor(defaultExecutionId = 'system') {
    this.defaultExecutionId = defaultExecutionId;
  }

  _formatMessage(level, message, executionId = null) {
    const id = executionId || this.defaultExecutionId;
    const timestamp = new Date().toISOString();
    return `[${id}] [${timestamp}] [${level}] ${message}`;
  }

  _logWithLevel(level, message, executionId = null, data = null) {
    const formattedMessage = this._formatMessage(level, message, executionId);

    switch (level) {
      case LOG_LEVELS.DEBUG:
      case LOG_LEVELS.INFO:
        console.log(formattedMessage);
        break;
      case LOG_LEVELS.WARN:
        console.warn(formattedMessage);
        break;
      case LOG_LEVELS.ERROR:
        console.error(formattedMessage);
        break;
    }

    if (data) {
      console.log(`[${executionId || this.defaultExecutionId}] Data:`, JSON.stringify(data, null, 2));
    }
  }

  // Info level logging
  info(message, executionId = null, data = null) {
    this._logWithLevel(LOG_LEVELS.INFO, message, executionId, data);
  }

  // Debug level logging
  debug(message, executionId = null, data = null) {
    this._logWithLevel(LOG_LEVELS.DEBUG, message, executionId, data);
  }

  // Warning level logging
  warn(message, executionId = null, data = null) {
    this._logWithLevel(LOG_LEVELS.WARN, message, executionId, data);
  }

  // Error level logging
  error(message, executionId = null, error = null, additionalData = null) {
    this._logWithLevel(LOG_LEVELS.ERROR, message, executionId);

    if (error) {
      const errorData = {
        message: error.message,
        stack: error.stack,
        ...(additionalData || {})
      };
      console.error(`[${executionId || this.defaultExecutionId}] Error Details:`, errorData);
    }
  }

  // Specialized logging methods for common patterns

  // Log function start
  startFunction(functionName, executionId = null, params = null) {
    const separator = '='.repeat(50);
    this.info(`${separator} ${functionName.toUpperCase()} STARTED ${separator}`, executionId);

    if (params) {
      this.info(`Function parameters:`, executionId, params);
    }
  }

  // Log function end
  endFunction(functionName, executionId = null, result = null) {
    const separator = '='.repeat(50);
    this.info(`${separator} ${functionName.toUpperCase()} ENDED ${separator}`, executionId);

    if (result) {
      this.info(`Function result:`, executionId, result);
    }
  }

  // Log transaction processing
  transaction(action, reference, executionId = null, details = null) {
    this.info(`Transaction ${action}: ${reference}`, executionId, details);
  }

  // Log payment processing
  payment(action, reference, amount = null, executionId = null) {
    const amountStr = amount ? ` - ₦${amount.toLocaleString()}` : '';
    this.info(`Payment ${action}: ${reference}${amountStr}`, executionId);
  }

  // Log database operations
  database(operation, collection, documentId = null, executionId = null) {
    const docStr = documentId ? `/${documentId}` : '';
    this.info(`Database ${operation}: ${collection}${docStr}`, executionId);
  }

  // Log email operations
  email(action, recipient, subject = null, executionId = null) {
    const subjectStr = subject ? ` - ${subject}` : '';
    this.info(`Email ${action}: ${recipient}${subjectStr}`, executionId);
  }

  // Log notification operations
  notification(action, userId, title = null, executionId = null) {
    const titleStr = title ? ` - ${title}` : '';
    this.info(`Notification ${action}: User ${userId}${titleStr}`, executionId);
  }

  // Log API calls
  apiCall(method, url, status = null, executionId = null) {
    const statusStr = status ? ` (${status})` : '';
    this.info(`API ${method}: ${url}${statusStr}`, executionId);
  }

  // Log validation results
  validation(field, isValid, errorMessage = null, executionId = null) {
    if (isValid) {
      this.info(`Validation passed: ${field}`, executionId);
    } else {
      this.warn(`Validation failed: ${field} - ${errorMessage}`, executionId);
    }
  }

  // Log statistics updates
  stats(action, metric, value = null, executionId = null) {
    const valueStr = value !== null ? ` = ${value}` : '';
    this.info(`Stats ${action}: ${metric}${valueStr}`, executionId);
  }

  // Log batch operations
  batch(action, count, executionId = null) {
    this.info(`Batch ${action}: ${count} operations`, executionId);
  }

  // Log success operations with checkmark
  success(message, executionId = null, data = null) {
    this.info(`✅ ${message}`, executionId, data);
  }

  // Log critical errors with X mark
  critical(message, executionId = null, error = null, additionalData = null) {
    this.error(`❌ CRITICAL ERROR: ${message}`, executionId, error, additionalData);
  }

  // Log warnings with warning emoji
  warning(message, executionId = null, data = null) {
    this.warn(`⚠️ ${message}`, executionId, data);
  }

  // Log processing with circular arrow
  processing(message, executionId = null, data = null) {
    this.info(`🔄 ${message}`, executionId, data);
  }

  // Log saving operations with floppy disk
  saving(message, executionId = null, data = null) {
    this.info(`💾 ${message}`, executionId, data);
  }

  // Log performance metrics
  performance(operation, duration, executionId = null, data = null) {
    this.info(`⚡ Performance ${operation}: ${duration}ms`, executionId, data);
  }

  // Log security events
  security(action, message, executionId = null, data = null) {
    this.info(`🔒 Security ${action}: ${message}`, executionId, data);
  }

  // Log webhook events
  webhook(action, eventType, executionId = null, data = null) {
    this.info(`🔗 Webhook ${action}: ${eventType}`, executionId, data);
  }

  // Log health checks
  health(service, status, executionId = null, data = null) {
    const emoji = status === 'HEALTHY' ? '✅' : '❌';
    this.info(`${emoji} Health ${service}: ${status}`, executionId, data);
  }
}

// Create a default logger instance
const logger = new Logger();

// Export both the class and default instance
module.exports = {
  Logger,
  logger,
  LOG_LEVELS
};