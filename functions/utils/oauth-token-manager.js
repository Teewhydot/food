// ========================================================================
// OAuth 2.0 Token Manager for Flutterwave v4 API
// ========================================================================

const axios = require('axios');
const { logger } = require('./logger');
const { ENVIRONMENT, FLUTTERWAVE } = require('./constants');

class OAuthTokenManager {
  constructor() {
    this.tokenCache = new Map();
    this.clientId = ENVIRONMENT.FLUTTERWAVE_CLIENT_ID;
    this.clientSecret = ENVIRONMENT.FLUTTERWAVE_CLIENT_SECRET;
    this.tokenUrl = FLUTTERWAVE.OAUTH_TOKEN_URL;
  }

  // ========================================================================
  // Token Generation and Refresh
  // ========================================================================

  async getValidToken(executionId = 'oauth-token') {
    try {
      const cacheKey = FLUTTERWAVE.OAUTH.TOKEN_CACHE_KEY;
      const cachedToken = this.tokenCache.get(cacheKey);

      // Check if cached token exists and is still valid
      if (cachedToken && this.isTokenValid(cachedToken)) {
        logger.success('Using cached OAuth token', executionId, {
          expiresIn: Math.floor((cachedToken.expiresAt - Date.now()) / 1000)
        });
        return cachedToken.accessToken;
      }

      // Generate new token if cache is empty or expired
      logger.info('Refreshing OAuth token', executionId);
      const newToken = await this.refreshToken(executionId);
      return newToken;
    } catch (error) {
      logger.error('Failed to get valid OAuth token', executionId, error);
      throw new Error(`OAuth token acquisition failed: ${error.message}`);
    }
  }

  async refreshToken(executionId = 'oauth-refresh') {
    const refreshStartTime = Date.now();

    try {
      if (!this.clientId || !this.clientSecret) {
        throw new Error('Flutterwave OAuth credentials not configured');
      }

      logger.apiCall('POST', this.tokenUrl, null, executionId);

      const response = await axios.post(
        this.tokenUrl,
        new URLSearchParams({
          client_id: this.clientId,
          client_secret: this.clientSecret,
          grant_type: FLUTTERWAVE.OAUTH.GRANT_TYPE
        }),
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          timeout: 60000, // Increase to 60 seconds
          maxRedirects: 0, // No redirects/retries
          validateStatus: function (status) {
            return status < 500; // Accept all status codes except 5xx server errors
          }
        }
      );

      const refreshEndTime = Date.now();
      const refreshDuration = refreshEndTime - refreshStartTime;

      logger.performance('OAUTH_REFRESH', refreshDuration, executionId, {
        statusCode: response.status
      });

      if (response.status === 200 && response.data.access_token) {
        const tokenData = response.data;
        const cacheKey = FLUTTERWAVE.OAUTH.TOKEN_CACHE_KEY;

        // Calculate expiry time with buffer
        const expiresInMs = (tokenData.expires_in * 1000) - FLUTTERWAVE.OAUTH.TOKEN_EXPIRY_BUFFER;
        const expiresAt = Date.now() + expiresInMs;

        // Cache the token
        this.tokenCache.set(cacheKey, {
          accessToken: tokenData.access_token,
          tokenType: tokenData.token_type,
          expiresIn: tokenData.expires_in,
          expiresAt: expiresAt,
          scope: tokenData.scope,
          refreshedAt: Date.now()
        });

        logger.success('OAuth token refreshed successfully', executionId, {
          tokenType: tokenData.token_type,
          expiresIn: tokenData.expires_in,
          scope: tokenData.scope
        });

        // Full token logging for manual testing (remove in production)
        console.log(`[${executionId}] 🔍 NEW OAUTH TOKEN REFRESHED: ${tokenData.access_token}`);
        console.log(`[${executionId}] 🔍 TOKEN EXPIRES IN: ${tokenData.expires_in} seconds`);

        return tokenData.access_token;
      } else {
        throw new Error(`OAuth token request failed: ${response.data.error || 'Unknown error'}`);
      }
    } catch (error) {
      logger.error('OAuth token refresh failed', executionId, error, {
        clientIdPresent: !!this.clientId,
        clientSecretPresent: !!this.clientSecret
      });

      // If it's a timeout error, provide specific guidance
      if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
        throw new Error('Timeout error: Flutterwave OAuth server took too long to respond');
      }

      // If it's a network error, provide helpful context
      if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
        throw new Error('Network error: Unable to reach Flutterwave OAuth server');
      }

      // If it's an authentication error, provide specific guidance
      if (error.response?.status === 401 || error.response?.status === 403) {
        throw new Error('Authentication failed: Please verify Flutterwave OAuth credentials');
      }

      throw new Error(`OAuth token refresh failed: ${error.message}`);
    }
  }

  // ========================================================================
  // Token Validation and Utilities
  // ========================================================================

  isTokenValid(tokenData) {
    if (!tokenData || !tokenData.accessToken || !tokenData.expiresAt) {
      return false;
    }

    // Check if token expires within the buffer time
    const timeUntilExpiry = tokenData.expiresAt - Date.now();
    const isValid = timeUntilExpiry > 0;

    if (!isValid) {
      logger.info('Cached token has expired', 'oauth-validation', {
        expiredAgo: Math.abs(timeUntilExpiry),
        refreshedAt: new Date(tokenData.refreshedAt).toISOString()
      });
    }

    return isValid;
  }

  getTokenInfo(executionId = 'oauth-info') {
    const cacheKey = FLUTTERWAVE.OAUTH.TOKEN_CACHE_KEY;
    const cachedToken = this.tokenCache.get(cacheKey);

    if (!cachedToken) {
      return { cached: false, message: 'No token in cache' };
    }

    const timeUntilExpiry = cachedToken.expiresAt - Date.now();
    const isValid = timeUntilExpiry > 0;

    return {
      cached: true,
      valid: isValid,
      tokenType: cachedToken.tokenType,
      expiresIn: Math.floor(timeUntilExpiry / 1000),
      scope: cachedToken.scope,
      refreshedAt: new Date(cachedToken.refreshedAt).toISOString()
    };
  }

  // ========================================================================
  // Cache Management
  // ========================================================================

  clearTokenCache(executionId = 'oauth-clear') {
    const cacheKey = FLUTTERWAVE.OAUTH.TOKEN_CACHE_KEY;
    const hadToken = this.tokenCache.has(cacheKey);

    this.tokenCache.delete(cacheKey);

    logger.info('OAuth token cache cleared', executionId, {
      hadCachedToken: hadToken
    });

    return hadToken;
  }

  // Force refresh of token (ignores cache)
  async forceRefresh(executionId = 'oauth-force-refresh') {
    logger.info('Forcing OAuth token refresh', executionId);
    this.clearTokenCache(executionId);
    return await this.refreshToken(executionId);
  }

  // ========================================================================
  // HTTP Header Generation
  // ========================================================================

  async getAuthorizationHeader(executionId = 'oauth-header') {
    try {
      const token = await this.getValidToken(executionId);
      const header = `Bearer ${token}`;
      console.log(`[${executionId}] Generated Authorization header: Bearer ***${token.slice(-8)}`);
      // Full token logging for manual testing (remove in production)
      console.log(`[${executionId}] 🔍 FULL OAUTH TOKEN FOR MANUAL TESTING: ${token}`);
      console.log(`[${executionId}] 🔍 FULL AUTHORIZATION HEADER: ${header}`);
      return header;
    } catch (error) {
      logger.error('Failed to generate authorization header', executionId, error);
      console.log(`[${executionId}] CRITICAL: No Authorization header - OAuth token generation failed!`);
      throw error;
    }
  }

  // ========================================================================
  // Health Check
  // ========================================================================

  async testOAuthConnection(executionId = 'oauth-health') {
    try {
      const token = await this.forceRefresh(executionId);
      const isHealthy = !!token;

      logger.health('FLUTTERWAVE_OAUTH', isHealthy ? 'HEALTHY' : 'UNHEALTHY', executionId);
      return isHealthy;
    } catch (error) {
      logger.health('FLUTTERWAVE_OAUTH', 'UNHEALTHY', executionId, error);
      return false;
    }
  }
}

// Export singleton instance
const oAuthTokenManager = new OAuthTokenManager();

module.exports = {
  OAuthTokenManager,
  oAuthTokenManager
};