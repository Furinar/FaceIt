# FaceIt 接口文档

## 一、接口概述

### 1.1 基本信息

- 基础路径：`/api/v1`
- 请求格式：`application/json`
- 响应格式：`application/json`
- 认证方式：Bearer Token (JWT)

### 1.2 统一响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1711065600000
}
```

### 1.3 错误码定义

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 二、认证接口

### 2.1 用户登录

**请求**
```
POST /api/v1/auth/login
```

**请求体**
```json
{
  "username": "string",
  "password": "string"
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "userId": "123456",
    "username": "testuser",
    "role": "user"
  }
}
```

### 2.2 用户注册

**请求**
```
POST /api/v1/auth/register
```

**请求体**
```json
{
  "username": "string",
  "password": "string",
  "confirmPassword": "string"
}
```

---

## 三、岗位接口

### 3.1 获取岗位列表

**请求**
```
GET /api/v1/positions
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "Java后端工程师",
      "code": "java_backend",
      "description": "负责Java后端开发",
      "skillTree": {
        "categories": [
          {
            "name": "Java基础",
            "skills": [
              {"name": "集合框架", "weight": 0.15},
              {"name": "多线程", "weight": 0.15}
            ]
          }
        ]
      }
    }
  ]
}
```

### 3.2 获取岗位详情

**请求**
```
GET /api/v1/positions/{id}
```

**路径参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | long | 是 | 岗位ID |

---

## 四、面试接口

### 4.1 创建面试会话

**请求**
```
POST /api/v1/interviews/sessions
```

**请求体**
```json
{
  "positionId": 1,
  "mode": "simulate",
  "difficulty": 2
}
```

**参数说明**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| positionId | long | 是 | 岗位ID |
| mode | string | 是 | 面试模式：free/simulate/focus |
| difficulty | int | 否 | 难度等级：1/2/3，默认2 |

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "sessionId": "sess_123456789",
    "positionId": 1,
    "positionName": "Java后端工程师",
    "mode": "simulate",
    "difficulty": 2,
    "status": "ongoing",
    "totalQuestions": 10,
    "currentQaSeq": 0,
    "startTime": "2024-03-22T10:00:00"
  }
}
```

### 4.2 获取当前题目

**请求**
```
GET /api/v1/interviews/sessions/{sessionId}/current
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "qaSeq": 1,
    "totalQuestions": 10,
    "question": {
      "id": 101,
      "category": "tech",
      "title": "HashMap底层原理",
      "content": "请介绍一下HashMap的底层实现原理，包括数据结构、扩容机制等。",
      "durationSeconds": 120
    }
  }
}
```

### 4.3 提交回答

**请求**
```
POST /api/v1/interviews/sessions/{sessionId}/answer
```

**请求体**
```json
{
  "qaSeq": 1,
  "answerType": "text",
  "answerContent": "HashMap底层是数组+链表+红黑树的结构..."
}
```

**参数说明**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| qaSeq | int | 是 | 问答序号 |
| answerType | string | 是 | 回答类型：text/voice |
| answerContent | string | 是 | 回答内容（文字） |
| voiceUrl | string | 否 | 语音文件URL（语音回答时） |
| voiceDuration | int | 否 | 语音时长（秒） |

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "qaSeq": 1,
    "score": 75.5,
    "techScore": 80.0,
    "depthScore": 70.0,
    "logicScore": 75.0,
    "matchScore": 77.0,
    "feedback": "回答较为完整，涵盖了HashMap的基本结构...",
    "analysis": {
      "strengths": ["回答了HashMap的基本结构", "提到了扩容机制"],
      "weaknesses": ["未提及线程安全问题"],
      "keyPointsHit": ["数据结构", "扩容机制"],
      "keyPointsMissed": ["线程安全"]
    },
    "hasFollowUp": true,
    "followUpQuestion": {
      "content": "你提到了HashMap不是线程安全的，那么在多线程场景下应该使用什么替代方案？"
    }
  }
}
```

### 4.4 结束面试

**请求**
```
POST /api/v1/interviews/sessions/{sessionId}/finish
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "sessionId": "sess_123456789",
    "status": "completed",
    "totalScore": 78.5,
    "techScore": 80.0,
    "depthScore": 75.0,
    "logicScore": 78.0,
    "matchScore": 81.0,
    "durationSeconds": 1800,
    "reportId": "report_123456789"
  }
}
```

### 4.5 获取面试报告

**请求**
```
GET /api/v1/interviews/sessions/{sessionId}/report
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "reportId": "report_123456789",
    "sessionId": "sess_123456789",
    "positionName": "Java后端工程师",
    "totalScore": 78.5,
    "scores": {
      "techCorrectness": 80.0,
      "knowledgeDepth": 75.0,
      "logicRigor": 78.0,
      "positionMatch": 81.0
    },
    "strengths": [
      "Java基础扎实，对集合框架理解深入",
      "能够清晰表达技术观点"
    ],
    "weaknesses": [
      "对分布式系统理解不够深入",
      "项目经验描述可以更加具体"
    ],
    "suggestions": [
      "建议深入学习Spring Cloud微服务架构",
      "准备项目经历时使用STAR法则"
    ],
    "recommendQuestions": [
      {"id": 201, "title": "Spring Bean生命周期"},
      {"id": 202, "title": "分布式事务解决方案"}
    ],
    "qaDetails": [
      {
        "seqNum": 1,
        "question": "HashMap底层原理",
        "score": 75.5,
        "analysis": "..."
      }
    ]
  }
}
```

---

## 五、用户接口

### 5.1 获取面试历史

**请求**
```
GET /api/v1/users/me/interviews
```

**查询参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认1 |
| size | int | 否 | 每页数量，默认10 |
| positionId | long | 否 | 岗位ID筛选 |

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 25,
    "page": 1,
    "size": 10,
    "records": [
      {
        "sessionId": "sess_123456789",
        "positionName": "Java后端工程师",
        "mode": "simulate",
        "totalScore": 78.5,
        "startTime": "2024-03-22T10:00:00",
        "durationSeconds": 1800,
        "status": "completed"
      }
    ]
  }
}
```

### 5.2 获取能力档案

**请求**
```
GET /api/v1/users/me/profile
```

**查询参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| positionId | long | 是 | 岗位ID |

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "positionId": 1,
    "positionName": "Java后端工程师",
    "totalInterviews": 15,
    "completedInterviews": 12,
    "avgScore": 76.5,
    "highestScore": 92.0,
    "skillScores": {
      "Java基础": {"score": 82, "count": 10},
      "Spring框架": {"score": 75, "count": 8},
      "数据库": {"score": 78, "count": 12}
    },
    "weakSkills": ["分布式", "微服务"],
    "strongSkills": ["Java基础", "数据库"],
    "lastInterviewTime": "2024-03-21T15:00:00"
  }
}
```

### 5.3 获取成长曲线

**请求**
```
GET /api/v1/users/me/growth
```

**查询参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| positionId | long | 是 | 岗位ID |
| dimension | string | 否 | 维度：total/tech/depth/logic/match |
| days | int | 否 | 天数，默认30 |

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "positionId": 1,
    "dimension": "total",
    "dataPoints": [
      {"date": "2024-03-01", "score": 65.0},
      {"date": "2024-03-05", "score": 68.5},
      {"date": "2024-03-10", "score": 72.0},
      {"date": "2024-03-15", "score": 75.5},
      {"date": "2024-03-20", "score": 78.0}
    ],
    "trend": "up",
    "improvement": 13.0
  }
}
```

---

## 六、题库管理接口（管理员）

### 6.1 创建题目

**请求**
```
POST /api/v1/admin/questions
```

**请求体**
```json
{
  "positionId": 1,
  "category": "tech",
  "difficulty": 2,
  "title": "HashMap底层原理",
  "content": "请介绍一下HashMap的底层实现原理...",
  "tags": ["Java", "集合", "HashMap"],
  "keyPoints": [
    {"point": "数据结构", "score": 20},
    {"point": "扩容机制", "score": 15}
  ],
  "referenceAnswer": "HashMap底层是...",
  "durationSeconds": 120
}
```

### 6.2 更新题目

**请求**
```
PUT /api/v1/admin/questions/{id}
```

### 6.3 删除题目

**请求**
```
DELETE /api/v1/admin/questions/{id}
```

### 6.4 获取题目列表

**请求**
```
GET /api/v1/admin/questions
```

**查询参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码 |
| size | int | 否 | 每页数量 |
| positionId | long | 否 | 岗位ID |
| category | string | 否 | 题目类别 |
| difficulty | int | 否 | 难度等级 |

---

## 七、语音接口

### 7.1 上传语音文件

**请求**
```
POST /api/v1/voice/upload
Content-Type: multipart/form-data
```

**请求体**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 语音文件 |
| sessionId | string | 是 | 会话ID |

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "voiceUrl": "https://storage.example.com/voice/xxx.wav",
    "duration": 45
  }
}
```

### 7.2 语音识别

**请求**
```
POST /api/v1/voice/recognize
```

**请求体**
```json
{
  "voiceUrl": "https://storage.example.com/voice/xxx.wav"
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "text": "HashMap底层是数组加链表的结构...",
    "confidence": 0.95
  }
}
```

---

## 八、SSE 流式接口

### 8.1 面试对话流

**请求**
```
GET /api/v1/interviews/sessions/{sessionId}/stream
Accept: text/event-stream
```

**事件类型**
| 事件 | 说明 |
|------|------|
| question | 面试官提问 |
| feedback | 即时反馈 |
| follow_up | 追问 |
| end | 面试结束 |

**事件格式**
```
event: question
data: {"content": "请介绍一下HashMap的底层实现原理..."}

event: feedback
data: {"score": 75.5, "feedback": "回答较为完整..."}

event: end
data: {"totalScore": 78.5}
```
