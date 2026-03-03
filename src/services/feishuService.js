const axios = require('axios');

class FeishuService {
  constructor() {
    this.appId = process.env.FEISHU_APP_ID;
    this.appSecret = process.env.FEISHU_APP_SECRET;
    this.accessToken = null;
    this.tokenExpireTime = 0;
  }

  // Get tenant access token
  async getTenantAccessToken() {
    const now = Date.now();

    // Return cached token if still valid
    if (this.accessToken && now < this.tokenExpireTime) {
      return this.accessToken;
    }

    try {
      const response = await axios.post(
        'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal',
        {
          app_id: this.appId,
          app_secret: this.appSecret
        }
      );

      if (response.data.code === 0) {
        this.accessToken = response.data.tenant_access_token;
        // Token expires in 2 hours, refresh 5 minutes early
        this.tokenExpireTime = now + (response.data.expire - 300) * 1000;
        return this.accessToken;
      } else {
        throw new Error(`Failed to get access token: ${response.data.msg}`);
      }
    } catch (error) {
      console.error('Error getting tenant access token:', error.message);
      throw error;
    }
  }

  // Get image content
  async getImageContent(messageId, imageKey) {
    try {
      const token = await this.getTenantAccessToken();

      const response = await axios.get(
        `https://open.feishu.cn/open-apis/im/v1/messages/${messageId}/resources/${imageKey}?type=image`,
        {
          headers: {
            'Authorization': `Bearer ${token}`
          },
          responseType: 'arraybuffer'
        }
      );

      // Convert to base64
      const base64Image = Buffer.from(response.data, 'binary').toString('base64');
      return base64Image;
    } catch (error) {
      console.error('Error getting image:', error.message);
      if (error.response) {
        console.error('Image API Error:', JSON.stringify(error.response.data));
      }
      throw error;
    }
  }

  // Send message to chat
  async sendMessage(chatId, content, receiveIdType = 'chat_id') {
    try {
      const token = await this.getTenantAccessToken();

      const payload = {
        receive_id: chatId,
        content: JSON.stringify({ text: content }),
        msg_type: 'text'
      };

      console.log('Sending message payload:', JSON.stringify(payload));
      console.log('Receive ID type:', receiveIdType);

      const response = await axios.post(
        `https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=${receiveIdType}`,
        payload,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.data.code === 0) {
        console.log('Message sent successfully');
        return response.data;
      } else {
        throw new Error(`Failed to send message: ${response.data.msg}`);
      }
    } catch (error) {
      console.error('Error sending message:', error.message);
      if (error.response) {
        console.error('API Error detail:', JSON.stringify(error.response.data));
      }
      throw error;
    }
  }

  // Reply to a message
  async sendReply(messageId, content) {
    try {
      const token = await this.getTenantAccessToken();

      const payload = {
        content: JSON.stringify({ text: content }),
        msg_type: 'text'
      };

      console.log('Sending reply to message:', messageId);
      console.log('Reply payload:', JSON.stringify(payload));

      const response = await axios.post(
        `https://open.feishu.cn/open-apis/im/v1/messages/${messageId}/reply`,
        payload,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.data.code === 0) {
        console.log('Reply sent successfully');
        return response.data;
      } else {
        throw new Error(`Failed to send reply: ${response.data.msg}`);
      }
    } catch (error) {
      console.error('Error sending reply:', error.message);
      if (error.response) {
        console.error('Reply API Error detail:', JSON.stringify(error.response.data));
      }
      throw error;
    }
  }
}

module.exports = new FeishuService();
