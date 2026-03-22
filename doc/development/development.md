# FaceIt 开发文档

## 一、开发环境搭建

### 1.1 系统要求

| 软件 | 版本要求 |
|------|---------|
| JDK | 17+ |
| Node.js | 18+ |
| MySQL | 8.0+ |
| Redis | 7.0+ |
| Maven | 3.8+ |
| Docker | 20+ |

### 1.2 后端环境搭建

#### 1.2.1 克隆项目
```bash
git clone https://github.com/your-team/faceit.git
cd faceit
```

#### 1.2.2 安装JDK 17
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-17-jdk

# macOS
brew install openjdk@17

# 验证安装
java -version
```

#### 1.2.3 安装Maven
```bash
# Ubuntu/Debian
sudo apt install maven

# macOS
brew install maven

# 验证安装
mvn -version
```

#### 1.2.4 启动MySQL
```bash
# Docker方式
docker run -d --name faceit-mysql \
  -e MYSQL_ROOT_PASSWORD=root123 \
  -e MYSQL_DATABASE=faceit \
  -p 3306:3306 \
  mysql:8.0

# 或使用本地安装
mysql -u root -p
CREATE DATABASE faceit DEFAULT CHARACTER SET utf8mb4;
```

#### 1.2.5 启动Redis
```bash
# Docker方式
docker run -d --name faceit-redis \
  -p 6379:6379 \
  redis:7.0

# 验证连接
redis-cli ping
```

#### 1.2.6 启动Milvus
```bash
# Docker Compose方式
docker run -d --name milvus-standalone \
  -p 19530:19530 \
  -p 9091:9091 \
  milvusdb/milvus:v2.6.6 standalone
```

#### 1.2.7 配置application.yaml
```yaml
# 复制配置模板
cp bootstrap/src/main/resources/application.yaml.example bootstrap/src/main/resources/application.yaml

# 编辑配置文件
# 修改数据库连接、Redis连接、大模型API密钥等
```

#### 1.2.8 初始化数据库
```bash
# 执行建表脚本
mysql -u root -p faceit < resources/database/schema_faceit.sql

# 执行初始化数据
mysql -u root -p faceit < resources/database/init_data_faceit.sql
```

#### 1.2.9 启动后端服务
```bash
cd faceit
mvn clean install -DskipTests
cd bootstrap
mvn spring-boot:run
```

### 1.3 前端环境搭建

#### 1.3.1 安装Node.js
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# macOS
brew install node@18

# 验证安装
node -version
npm -version
```

#### 1.3.2 安装依赖
```bash
cd frontend
npm install
```

#### 1.3.3 配置环境变量
```bash
# 创建环境配置文件
cp .env.example .env

# 编辑.env文件
VITE_API_BASE_URL=http://localhost:8080/api/v1
```

#### 1.3.4 启动前端服务
```bash
npm run dev
```

---

## 二、项目结构

### 2.1 后端项目结构

```
faceit/
├── bootstrap/                    # 应用启动模块
│   └── src/main/java/com/nageoffer/ai/faceit/
│       ├── interview/            # 面试服务
│       │   ├── controller/       # 控制器
│       │   ├── service/          # 服务层
│       │   ├── engine/           # 面试引擎
│       │   ├── state/            # 状态机
│       │   └── dao/              # 数据访问层
│       ├── evaluation/           # 评估服务
│       │   ├── controller/
│       │   ├── service/
│       │   ├── analyzer/         # 分析器
│       │   └── scorer/           # 评分器
│       ├── question/             # 题库服务
│       │   ├── controller/
│       │   ├── service/
│       │   └── knowledge/        # 知识库
│       ├── user/                 # 用户服务
│       │   ├── controller/
│       │   ├── service/
│       │   └── recommendation/   # 推荐服务
│       └── FaceItApplication.java
├── framework/                    # 基础框架模块
│   └── src/main/java/
│       ├── common/               # 公共组件
│       ├── config/               # 配置类
│       ├── exception/            # 异常处理
│       └── utils/                # 工具类
├── infra-ai/                     # AI基础设施模块
│   └── src/main/java/
│       ├── llm/                  # 大模型客户端
│       ├── voice/                # 语音服务
│       └── vector/               # 向量存储
└── resources/
    ├── database/                 # 数据库脚本
    └── docker/                   # Docker配置
```

### 2.2 前端项目结构

```
frontend/
├── public/                       # 静态资源
├── src/
│   ├── components/               # 组件
│   │   ├── common/               # 公共组件
│   │   ├── interview/            # 面试相关组件
│   │   ├── report/               # 报告相关组件
│   │   └── ui/                   # UI基础组件
│   ├── pages/                    # 页面
│   │   ├── home/                 # 首页/面试大厅
│   │   ├── interview/            # 模拟面试
│   │   ├── report/               # 评估报告
│   │   ├── growth/               # 成长中心
│   │   └── admin/                # 管理后台
│   ├── hooks/                    # 自定义Hooks
│   ├── services/                 # API服务
│   ├── stores/                   # 状态管理
│   ├── types/                    # 类型定义
│   └── utils/                    # 工具函数
├── package.json
└── vite.config.ts
```

---

## 三、核心功能开发指南

### 3.1 面试服务开发

#### 3.1.1 创建面试会话

```java
@Service
public class InterviewServiceImpl implements InterviewService {

    @Autowired
    private InterviewSessionMapper sessionMapper;
    
    @Autowired
    private QuestionSelector questionSelector;

    @Override
    @Transactional
    public InterviewSessionVO createSession(CreateSessionRequest request, String userId) {
        InterviewSessionDO session = new InterviewSessionDO();
        session.setSessionId(generateSessionId());
        session.setUserId(userId);
        session.setPositionId(request.getPositionId());
        session.setMode(request.getMode());
        session.setDifficulty(request.getDifficulty());
        session.setStatus("ongoing");
        session.setStartTime(LocalDateTime.now());
        
        List<Long> questionIds = questionSelector.selectQuestions(
            request.getPositionId(), 
            request.getDifficulty()
        );
        session.setQuestionIds(JSON.toJSONString(questionIds));
        session.setTotalQuestions(questionIds.size());
        
        sessionMapper.insert(session);
        
        return convertToVO(session);
    }
}
```

#### 3.1.2 面试状态机

```java
public enum InterviewState {
    IDLE,           // 空闲
    PREPARING,      // 准备中
    ANSWERING,      // 回答中
    EVALUATING,     // 评估中
    NEXT_QA,        // 下一题
    COMPLETED,      // 已完成
    CANCELLED       // 已取消
}

@Component
public class InterviewStateMachine {
    
    private static final Map<InterviewState, Set<InterviewState>> TRANSITIONS = Map.of(
        InterviewState.IDLE, Set.of(InterviewState.PREPARING),
        InterviewState.PREPARING, Set.of(InterviewState.ANSWERING, InterviewState.CANCELLED),
        InterviewState.ANSWERING, Set.of(InterviewState.EVALUATING),
        InterviewState.EVALUATING, Set.of(InterviewState.NEXT_QA, InterviewState.COMPLETED),
        InterviewState.NEXT_QA, Set.of(InterviewState.ANSWERING, InterviewState.COMPLETED)
    );
    
    public boolean canTransition(InterviewState from, InterviewState to) {
        return TRANSITIONS.getOrDefault(from, Set.of()).contains(to);
    }
}
```

### 3.2 评估服务开发

#### 3.2.1 内容分析器

```java
@Component
public class ContentAnalyzer {

    @Autowired
    private LLMClient llmClient;

    public AnalysisResult analyze(String question, String answer, Position position) {
        String prompt = buildAnalysisPrompt(question, answer, position);
        
        String response = llmClient.chat(prompt);
        
        return parseAnalysisResult(response);
    }
    
    private String buildAnalysisPrompt(String question, String answer, Position position) {
        return String.format("""
            你是一位资深的%s面试官，请对以下回答进行专业评估。
            
            面试问题：%s
            候选人回答：%s
            
            请从以下维度进行评分（0-100分）：
            1. 技术正确性：回答的技术内容是否正确
            2. 知识深度：对知识点的理解深度
            3. 逻辑严谨性：回答的逻辑是否清晰严谨
            4. 岗位匹配度：回答是否符合岗位要求
            
            请以JSON格式返回评估结果。
            """, position.getName(), question, answer);
    }
}
```

### 3.3 RAG检索开发

#### 3.3.1 知识库检索

```java
@Service
public class KnowledgeRetriever {

    @Autowired
    private MilvusVectorStoreService vectorStore;
    
    @Autowired
    private EmbeddingService embeddingService;

    public List<RetrievedChunk> retrieve(String query, int topK) {
        float[] queryVector = embeddingService.embed(query);
        
        SearchParam searchParam = SearchParam.newBuilder()
            .withCollectionName(COLLECTION_NAME)
            .withVectors(Collections.singletonList(queryVector))
            .withTopK(topK)
            .build();
        
        R<SearchResults> results = vectorStore.search(searchParam);
        
        return convertToChunks(results);
    }
}
```

---

## 四、前端开发指南

### 4.1 页面组件开发

#### 4.1.1 面试页面

```tsx
import { useState, useEffect } from 'react';
import { useInterview } from '@/hooks/useInterview';
import { ChatInput } from '@/components/interview/ChatInput';
import { MessageList } from '@/components/interview/MessageList';

export function InterviewPage() {
  const { session, currentQuestion, submitAnswer, loading } = useInterview();
  const [messages, setMessages] = useState<Message[]>([]);

  const handleSubmit = async (content: string, type: 'text' | 'voice') => {
    const feedback = await submitAnswer(content, type);
    setMessages(prev => [
      ...prev,
      { role: 'user', content },
      { role: 'assistant', content: feedback.feedback }
    ]);
  };

  return (
    <div className="flex flex-col h-screen">
      <MessageList messages={messages} />
      <ChatInput onSubmit={handleSubmit} loading={loading} />
    </div>
  );
}
```

#### 4.1.2 语音输入组件

```tsx
import { useState, useRef } from 'react';
import { useVoiceRecognition } from '@/hooks/useVoiceRecognition';

export function VoiceInput({ onSubmit }: { onSubmit: (text: string) => void }) {
  const [isRecording, setIsRecording] = useState(false);
  const { startRecording, stopRecording, transcript } = useVoiceRecognition();

  const handleToggle = async () => {
    if (isRecording) {
      const text = await stopRecording();
      onSubmit(text);
    } else {
      startRecording();
    }
    setIsRecording(!isRecording);
  };

  return (
    <button onClick={handleToggle}>
      {isRecording ? '停止录音' : '开始录音'}
    </button>
  );
}
```

### 4.2 状态管理

```typescript
import { create } from 'zustand';

interface InterviewStore {
  session: InterviewSession | null;
  currentQuestion: Question | null;
  messages: Message[];
  setSession: (session: InterviewSession) => void;
  addMessage: (message: Message) => void;
  clearSession: () => void;
}

export const useInterviewStore = create<InterviewStore>((set) => ({
  session: null,
  currentQuestion: null,
  messages: [],
  setSession: (session) => set({ session }),
  addMessage: (message) => set((state) => ({ 
    messages: [...state.messages, message] 
  })),
  clearSession: () => set({ session: null, messages: [] }),
}));
```

---

## 五、测试指南

### 5.1 单元测试

```java
@SpringBootTest
class InterviewServiceTest {

    @Autowired
    private InterviewService interviewService;

    @Test
    void testCreateSession() {
        CreateSessionRequest request = new CreateSessionRequest();
        request.setPositionId(1L);
        request.setMode("simulate");
        request.setDifficulty(2);

        InterviewSessionVO session = interviewService.createSession(request, "test-user");

        assertNotNull(session);
        assertNotNull(session.getSessionId());
        assertEquals("ongoing", session.getStatus());
    }
}
```

### 5.2 集成测试

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class InterviewControllerTest {

    @Autowired
    private WebTestClient webTestClient;

    @Test
    void testCreateSession() {
        CreateSessionRequest request = new CreateSessionRequest();
        request.setPositionId(1L);
        request.setMode("simulate");

        webTestClient.post()
            .uri("/api/v1/interviews/sessions")
            .header("Authorization", "Bearer " + getToken())
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(request)
            .exchange()
            .expectStatus().isOk()
            .expectBody()
            .jsonPath("$.data.sessionId").exists();
    }
}
```

---

## 六、部署指南

### 6.1 Docker部署

```dockerfile
# Dockerfile - 后端
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY bootstrap/target/bootstrap.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

# Dockerfile - 前端
FROM node:18-alpine as build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
```

### 6.2 Docker Compose

```yaml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: faceit
    ports:
      - "3306:3306"

  redis:
    image: redis:7.0
    ports:
      - "6379:6379"

  milvus:
    image: milvusdb/milvus:v2.6.6
    ports:
      - "19530:19530"

  backend:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - mysql
      - redis
      - milvus

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
```

---

## 七、常见问题

### 7.1 开发环境问题

**Q: Milvus连接失败？**
A: 检查Milvus是否正常启动，端口是否开放。

**Q: 大模型API调用超时？**
A: 检查网络连接，增加超时时间配置。

### 7.2 编译问题

**Q: Maven编译失败？**
A: 检查JDK版本是否为17，清理本地Maven仓库缓存。

**Q: 前端依赖安装失败？**
A: 尝试使用国内镜像源：`npm config set registry https://registry.npmmirror.com`
