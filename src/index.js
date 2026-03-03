require('dotenv').config();
const express = require('express');
const feishuService = require('./services/feishuService');
const deepseekService = require('./services/deepseekService');
const claudeService = require('./services/claudeService');

const app = express();

// 添加请求日志
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// 使用更宽松的 JSON 解析配置
app.use(express.json({
  verify: (req, res, buf) => {
    req.rawBody = buf.toString();
  }
}));

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  console.error('Request body:', req.rawBody);
  res.status(400).json({ error: err.message });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Feishu bot is running' });
});

// Feishu webhook endpoint
app.post('/webhook', async (req, res) => {
  console.log('Raw body:', req.rawBody);

  const body = req.body;
  const { type, challenge, event, schema, header } = body;

  console.log('Parsed webhook:', JSON.stringify(body, null, 2));

  // Handle URL verification
  if (type === 'url_verification') {
    return res.json({ challenge });
  }

  res.json({ code: 0 });

  try {
    // v2.0 format: { schema: "2.0", header: { event_type: "im.message.receive_v1" }, event: {...} }
    if (schema === '2.0' && header?.event_type === 'im.message.receive_v1' && event) {
      await handleMessage(event);
    }
    // v1.0 format: { type: "event_callback", event: { type: "message", ... } }
    else if (type === 'event_callback' && event?.type === 'message' && event.message) {
      await handleMessage(event);
    }
  } catch (error) {
    console.error('Error handling message:', error.message);
  }
});

async function handleMessage(event) {
  const { message, sender } = event;

  console.log('Full event data:', JSON.stringify(event, null, 2));

  // Skip bot's own messages
  if (sender.sender_type === 'app') {
    return;
  }

  const messageType = message.message_type;
  const chatId = message.chat_id;
  const chatType = message.chat_type;
  const messageId = message.message_id;

  console.log(`Chat ID: ${chatId}`);
  console.log(`Chat Type: ${chatType}`);
  console.log(`Message ID: ${messageId}`);

  if (!chatId) {
    console.error('No chat_id found in message');
    return;
  }

  // Handle text messages
  if (messageType === 'text') {
    const content = JSON.parse(message.content);
    const userMessage = content.text;

    console.log(`Received text message: ${userMessage}`);

    try {
      // Generate AI response using DeepSeek
      const aiResponse = await deepseekService.generateResponse(userMessage);
      console.log(`AI Response: ${aiResponse}`);

      // Send message to chat instead of replying
      await feishuService.sendMessage(chatId, aiResponse, 'chat_id');
    } catch (error) {
      console.error('Error in text message handling:', error.message);
    }
  }
  // Handle image messages
  else if (messageType === 'image') {
    const content = JSON.parse(message.content);
    const imageKey = content.image_key;

    console.log(`Received image message, image_key: ${imageKey}`);

    try {
      // Download image from Feishu
      const base64Image = await feishuService.getImageContent(messageId, imageKey);
      console.log('Image downloaded successfully');

      // Generate copywriting from image using Claude
      const copywriting = await claudeService.generateCopywritingFromImage(base64Image);
      console.log(`Generated copywriting: ${copywriting}`);

      // Try to reply to the message directly
      await feishuService.sendReply(messageId, copywriting);
    } catch (error) {
      console.error('Error processing image:', error.message);
      try {
        await feishuService.sendReply(messageId, '抱歉，处理图片时出错了，请稍后再试。');
      } catch (replyError) {
        console.error('Failed to send error message:', replyError.message);
      }
    }
  }
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Feishu bot server running on port ${PORT}`);
  console.log(`Webhook URL: http://localhost:${PORT}/webhook`);
});
