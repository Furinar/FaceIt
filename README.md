# FaceIt - AI 模拟面试与能力提升平台

> 面向计算机专业学生的智能面试训练系统

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/)
[![Vue](https://img.shields.io/badge/vue-3.x-green.svg)](https://vuejs.org/)

---

## 📖 项目简介

FaceIt 是一个基于大语言模型（LLM）和检索增强生成（RAG）技术的 AI 模拟面试平台，旨在帮助计算机专业学生提升面试技能和就业竞争力。

### 核心特性

- 🎯 **岗位专属化**：支持 Java 后端、Web 前端等多个岗位的差异化面试
- 🗣️ **多模态交互**：支持语音和文字双输入，真实模拟面试场景
- 🤖 **智能追问**：AI 面试官能够根据回答动态追问，挖掘技术深度
- 📊 **多维度评估**：从技术、逻辑、表达、匹配度等多角度评分
- 📈 **成长追踪**：可视化展示能力成长曲线，精准定位薄弱环节
- 💡 **智能推荐**：基于评估结果推荐个性化练习计划

---

## 🏗️ 技术架构

### 前端技术栈

- **框架**：Vue 3 + Vite
- **UI 组件**：Element Plus
- **状态管理**：Pinia
- **数据可视化**：ECharts
- **语音处理**：MediaRecorder API

### 后端技术栈

- **框架**：Spring Boot 3.x / FastAPI
- **数据库**：MySQL 8.0 + Redis 7.0
- **向量数据库**：Milvus 2.3
- **认证**：JWT + Spring Security

### AI 技术栈

- **大语言模型**：智谱 GLM-4 / 文心一言 / 讯飞星火
- **RAG 框架**：LangChain / LlamaIndex
- **语音识别**：讯飞 ASR / 阿里云 ASR
- **语音合成**：讯飞 TTS / 阿里云 TTS

---

## 📁 项目结构

```
FaceIt/
├── doc/                          # 项目文档
│   ├── 项目详细方案.md
│   ├── 系统架构设计.md
│   ├── 数据库设计.md
│   ├── 接口说明书.md
│   ├── 开发流程与规划.md
│   ├── 团队分工建议.md
│   ├── 需求说明书.md
│   ├── 赛题.md
│   ├── 评分规则.md
│   └── sql/
│       └── schema.sql            # 数据库建表脚本
├── backend/                      # 后端服务
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/            # Java 源码
│   │   │   └── resources/       # 配置文件
│   │   └── test/                # 测试代码
│   └── pom.xml                  # Maven 配置
├── frontend/                     # 前端应用
│   ├── src/
│   │   ├── components/          # Vue 组件
│   │   ├── views/               # 页面视图
│   │   ├── router/              # 路由配置
│   │   ├── store/               # 状态管理
│   │   └── api/                 # API 接口
│   └── package.json
├── ai-engine/                    # AI 推理服务
│   ├── rag/                     # RAG 检索模块
│   ├── llm/                     # 大模型接口
│   ├── evaluation/              # 评估算法
│   └── requirements.txt
├── knowledge-base/               # 本地知识库
│   ├── java_backend/            # Java 后端知识库
│   │   ├── tech_stack/
│   │   ├── interview_questions/
│   │   └── best_answers/
│   └── web_frontend/            # Web 前端知识库
│       ├── tech_stack/
│       ├── interview_questions/
│       └── best_answers/
├── docker-compose.yml           # Docker 编排配置
└── README.md                    # 项目说明
```

---

## 🚀 快速开始

### 环境要求

- **Node.js**：>= 16.x
- **Java**：>= 17
- **Python**：>= 3.9
- **MySQL**：>= 8.0
- **Redis**：>= 7.0
- **Docker**：>= 20.x（可选）

### 1. 克隆项目

```bash
git clone https://github.com/your-org/faceit.git
cd faceit
```

### 2. 启动数据库（Docker）

```bash
docker-compose up -d mysql redis milvus
```

### 3. 初始化数据库

```bash
mysql -u root -p < doc/sql/schema.sql
```

### 4. 启动后端服务

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

后端服务将在 `http://localhost:8080` 启动。

### 5. 启动 AI 推理服务

```bash
cd ai-engine
pip install -r requirements.txt
python main.py
```

AI 服务将在 `http://localhost:8000` 启动。

### 6. 启动前端应用

```bash
cd frontend
npm install
npm run dev
```

前端应用将在 `http://localhost:5173` 启动。

### 7. 访问应用

打开浏览器访问 `http://localhost:5173`，注册账号后即可开始使用。

---

## 📚 使用指南

### 1. 注册与登录

- 访问首页，点击"注册"按钮
- 填写用户名、邮箱、密码等信息
- 选择意向岗位（Java 后端 / Web 前端）

### 2. 开始模拟面试

- 登录后进入"开始面试"页面
- 选择面试岗位和模式（基础/全真/专项）
- 设置面试时长（10/20/30 分钟）
- 点击"开始面试"进入面试室

### 3. 面试对话

- 支持语音输入（点击麦克风按钮）或文字输入
- AI 面试官会根据你的回答进行追问
- 面试过程中可以随时查看剩余时间
- 完成后点击"结束面试"

### 4. 查看评估报告

- 面试结束后，系统自动生成评估报告
- 查看综合得分、评级和雷达图
- 查看逐题点评和改进建议
- 查看薄弱环节分析

### 5. 能力提升

- 根据评估报告推荐的练习计划进行训练
- 查看成长曲线，追踪能力提升
- 浏览知识库，学习相关技术知识

---

## 🔧 配置说明

### 后端配置

编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/faceit
    username: root
    password: your_password
  redis:
    host: localhost
    port: 6379

jwt:
  secret: your_jwt_secret
  expiration: 7200

ai:
  llm:
    api_key: your_glm4_api_key
    model: glm-4
  asr:
    api_key: your_asr_api_key
  tts:
    api_key: your_tts_api_key
```

### AI 服务配置

编辑 `ai-engine/config.py`：

```python
# 大模型配置
LLM_API_KEY = "your_glm4_api_key"
LLM_MODEL = "glm-4"

# 向量数据库配置
MILVUS_HOST = "localhost"
MILVUS_PORT = 19530

# Embedding 模型配置
EMBEDDING_MODEL = "text-embedding-3"
```

---

## 📊 API 文档

完整的 API 接口文档请查看：[接口说明书](doc/接口说明书.md)

### 核心接口示例

**用户登录**：
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "zhangsan",
  "password": "Password123!"
}
```

**创建面试会话**：
```bash
POST /api/v1/interview/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "job_position": "java_backend",
  "interview_mode": "full",
  "duration_minutes": 30
}
```

**发送面试消息**：
```bash
POST /api/v1/interview/{session_id}/message
Authorization: Bearer {token}
Content-Type: application/json

{
  "message_type": "text",
  "content": "我叫张三，来自清华大学..."
}
```

---

## 🧪 测试

### 后端测试

```bash
cd backend
mvn test
```

### 前端测试

```bash
cd frontend
npm run test
```

### API 测试

使用 Postman 或 Apifox 导入 `doc/apifox-collection.json` 进行接口测试。

---

## 📦 部署

### Docker 部署（推荐）

```bash
# 构建镜像
docker-compose build

# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 手动部署

详细部署步骤请参考：[部署文档](doc/deployment.md)

---

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

---

## 👥 团队成员

- **项目经理**：负责项目统筹与文档整理
- **AI 算法工程师**：负责大模型集成与 RAG 系统
- **后端工程师**：负责 API 开发与数据库设计
- **前端工程师**：负责用户界面与交互开发
- **测试工程师**：负责质量保障与测试

详细分工请查看：[团队分工建议](doc/团队分工建议.md)

---

## 📞 联系我们

- **项目主页**：https://github.com/your-org/faceit
- **问题反馈**：https://github.com/your-org/faceit/issues
- **邮箱**：support@faceit.com

---

## 🙏 致谢

感谢以下开源项目和服务：

- [Vue.js](https://vuejs.org/)
- [Spring Boot](https://spring.io/projects/spring-boot)
- [LangChain](https://www.langchain.com/)
- [智谱 AI](https://www.zhipuai.cn/)
- [Element Plus](https://element-plus.org/)
- [ECharts](https://echarts.apache.org/)

---

## 📈 项目状态

- ✅ 需求分析与架构设计
- ✅ 数据库设计
- ✅ API 接口设计
- 🚧 后端服务开发中
- 🚧 前端界面开发中
- 🚧 AI 推理服务开发中
- ⏳ 测试与优化
- ⏳ 文档完善

---

> **提示**：本项目为全国大学生服务外包创新创业大赛参赛作品，旨在解决高校学生面试准备痛点，提升就业竞争力。
