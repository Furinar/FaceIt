# FaceIt 数据库设计文档

## 一、数据库概述

### 1.1 数据库选型

| 数据库 | 版本 | 用途 |
|--------|------|------|
| MySQL | 8.0 | 关系型数据存储 |
| Milvus | 2.6 | 向量数据存储 |
| Redis | 7.0 | 缓存和会话存储 |

### 1.2 命名规范

- 表名：小写字母，使用下划线分隔，以 `t_` 为前缀
- 字段名：小写字母，使用下划线分隔
- 主键：`id`，使用 bigint 类型
- 外键：`{关联表}_id`

---

## 二、ER图

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│  t_position │       │t_interview_ │       │t_interview_ │
│   (岗位)    │◄──────│  question   │───────│   session   │
└─────────────┘       │  (题目)     │       │  (会话)     │
                      └─────────────┘       └──────┬──────┘
                                                   │
                      ┌─────────────┐              │
                      │t_interview_ │              │
                      │    qa       │◄─────────────┘
                      │  (问答)     │
                      └──────┬──────┘
                             │
                      ┌──────▼──────┐
                      │t_interview_ │
                      │   report    │
                      │  (报告)     │
                      └─────────────┘

┌─────────────┐       ┌─────────────┐
│   t_user    │       │t_user_      │
│  (用户)     │───────│  profile    │
└─────────────┘       │  (档案)     │
                      └─────────────┘
```

---

## 三、表结构设计

### 3.1 岗位表 (t_position)

```sql
CREATE TABLE `t_position` (
    `id` bigint NOT NULL COMMENT '主键ID',
    `name` varchar(64) NOT NULL COMMENT '岗位名称',
    `code` varchar(32) NOT NULL COMMENT '岗位编码',
    `description` text COMMENT '岗位描述',
    `skill_tree` json COMMENT '技能树JSON',
    `eval_weights` json COMMENT '评估权重配置',
    `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用：1启用 0禁用',
    `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
    `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除：0正常 1删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`),
    KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='岗位定义表';
```

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | bigint | 是 | 主键ID，使用雪花算法生成 |
| name | varchar(64) | 是 | 岗位名称，如"Java后端工程师" |
| code | varchar(32) | 是 | 岗位编码，如"java_backend" |
| description | text | 否 | 岗位描述 |
| skill_tree | json | 否 | 技能树配置，格式见下方 |
| eval_weights | json | 否 | 评估权重配置，格式见下方 |
| enabled | tinyint | 是 | 是否启用 |

**skill_tree 格式示例：**
```json
{
  "categories": [
    {
      "name": "Java基础",
      "skills": [
        {"name": "集合框架", "weight": 0.15},
        {"name": "多线程", "weight": 0.15},
        {"name": "JVM", "weight": 0.10}
      ]
    },
    {
      "name": "框架技术",
      "skills": [
        {"name": "Spring", "weight": 0.20},
        {"name": "MyBatis", "weight": 0.10}
      ]
    }
  ]
}
```

**eval_weights 格式示例：**
```json
{
  "tech_correctness": 0.30,
  "knowledge_depth": 0.25,
  "logic_rigor": 0.20,
  "position_match": 0.25
}
```

---

### 3.2 面试题目表 (t_interview_question)

```sql
CREATE TABLE `t_interview_question` (
    `id` bigint NOT NULL COMMENT '主键ID',
    `position_id` bigint NOT NULL COMMENT '岗位ID',
    `category` varchar(32) NOT NULL COMMENT '题目类别：tech技术/project项目/scene场景/behavior行为',
    `difficulty` tinyint NOT NULL COMMENT '难度等级：1初级/2中级/3高级',
    `title` varchar(256) NOT NULL COMMENT '题目标题',
    `content` text NOT NULL COMMENT '题目内容',
    `tags` json COMMENT '知识点标签',
    `key_points` json COMMENT '关键评分点',
    `bonus_points` json COMMENT '加分项',
    `deduct_points` json COMMENT '扣分项',
    `follow_ups` json COMMENT '追问题目ID列表',
    `reference_answer` text COMMENT '参考答案',
    `duration_seconds` int DEFAULT 120 COMMENT '建议回答时长(秒)',
    `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用',
    `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
    `update_by` varchar(64) DEFAULT NULL COMMENT '修改人',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除',
    PRIMARY KEY (`id`),
    KEY `idx_position_category` (`position_id`, `category`),
    KEY `idx_difficulty` (`difficulty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='面试题目表';
```

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| position_id | bigint | 是 | 关联岗位ID |
| category | varchar(32) | 是 | 题目类别 |
| difficulty | tinyint | 是 | 难度等级 |
| title | varchar(256) | 是 | 题目标题 |
| content | text | 是 | 题目详细内容 |
| tags | json | 否 | 知识点标签数组 |
| key_points | json | 否 | 关键评分点 |
| follow_ups | json | 否 | 追问题目ID数组 |

**key_points 格式示例：**
```json
[
  {"point": "解释HashMap的底层数据结构", "score": 20},
  {"point": "说明扩容机制", "score": 15},
  {"point": "提到线程安全问题", "score": 10}
]
```

---

### 3.3 面试会话表 (t_interview_session)

```sql
CREATE TABLE `t_interview_session` (
    `id` bigint NOT NULL COMMENT '主键ID',
    `session_id` varchar(64) NOT NULL COMMENT '会话ID',
    `user_id` varchar(64) NOT NULL COMMENT '用户ID',
    `position_id` bigint NOT NULL COMMENT '岗位ID',
    `mode` varchar(32) NOT NULL COMMENT '面试模式：free自由/simulate模拟/focus专项',
    `difficulty` tinyint DEFAULT 2 COMMENT '难度等级',
    `status` varchar(32) NOT NULL DEFAULT 'ongoing' COMMENT '状态：ongoing进行中/completed已完成/cancelled已取消',
    `current_qa_seq` int DEFAULT 0 COMMENT '当前问答序号',
    `total_questions` int DEFAULT 0 COMMENT '总题目数',
    `total_score` decimal(5,2) DEFAULT NULL COMMENT '总分(百分制)',
    `tech_score` decimal(5,2) DEFAULT NULL COMMENT '技术正确性得分',
    `depth_score` decimal(5,2) DEFAULT NULL COMMENT '知识深度得分',
    `logic_score` decimal(5,2) DEFAULT NULL COMMENT '逻辑严谨性得分',
    `match_score` decimal(5,2) DEFAULT NULL COMMENT '岗位匹配度得分',
    `expression_score` decimal(5,2) DEFAULT NULL COMMENT '表达得分',
    `start_time` datetime DEFAULT NULL COMMENT '开始时间',
    `end_time` datetime DEFAULT NULL COMMENT '结束时间',
    `duration_seconds` int DEFAULT NULL COMMENT '面试时长(秒)',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_session` (`session_id`),
    KEY `idx_user_time` (`user_id`, `start_time`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='面试会话表';
```

---

### 3.4 面试问答记录表 (t_interview_qa)

```sql
CREATE TABLE `t_interview_qa` (
    `id` bigint NOT NULL COMMENT '主键ID',
    `session_id` varchar(64) NOT NULL COMMENT '会话ID',
    `question_id` bigint DEFAULT NULL COMMENT '题目ID',
    `question_content` text NOT NULL COMMENT '问题内容',
    `answer_content` text COMMENT '回答内容',
    `answer_type` varchar(16) DEFAULT 'text' COMMENT '回答类型：text文字/voice语音',
    `voice_url` varchar(512) DEFAULT NULL COMMENT '语音文件URL',
    `voice_duration` int DEFAULT NULL COMMENT '语音时长(秒)',
    `ai_feedback` text COMMENT 'AI即时反馈',
    `score` decimal(5,2) DEFAULT NULL COMMENT '本题得分',
    `tech_score` decimal(5,2) DEFAULT NULL COMMENT '技术得分',
    `depth_score` decimal(5,2) DEFAULT NULL COMMENT '深度得分',
    `logic_score` decimal(5,2) DEFAULT NULL COMMENT '逻辑得分',
    `match_score` decimal(5,2) DEFAULT NULL COMMENT '匹配得分',
    `analysis` json COMMENT '详细分析JSON',
    `follow_up` tinyint DEFAULT 0 COMMENT '是否追问：0否 1是',
    `parent_qa_id` bigint DEFAULT NULL COMMENT '父问答ID(追问时)',
    `seq_num` int NOT NULL COMMENT '问答序号',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除',
    PRIMARY KEY (`id`),
    KEY `idx_session` (`session_id`),
    KEY `idx_question` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='面试问答记录表';
```

**analysis 格式示例：**
```json
{
  "strengths": ["回答了HashMap的基本结构", "提到了扩容机制"],
  "weaknesses": ["未提及线程安全问题", "对红黑树转换条件理解不深"],
  "key_points_hit": ["数据结构", "扩容机制"],
  "key_points_missed": ["线程安全", "红黑树转换"],
  "suggestions": ["建议深入学习ConcurrentHashMap", "理解红黑树转换阈值"]
}
```

---

### 3.5 面试报告表 (t_interview_report)

```sql
CREATE TABLE `t_interview_report` (
    `id` bigint NOT NULL COMMENT '主键ID',
    `session_id` varchar(64) NOT NULL COMMENT '会话ID',
    `user_id` varchar(64) NOT NULL COMMENT '用户ID',
    `position_id` bigint NOT NULL COMMENT '岗位ID',
    `report_content` longtext NOT NULL COMMENT '报告内容JSON',
    `strengths` json COMMENT '亮点列表',
    `weaknesses` json COMMENT '不足列表',
    `suggestions` json COMMENT '改进建议',
    `recommend_questions` json COMMENT '推荐练习题目ID列表',
    `recommend_resources` json COMMENT '推荐学习资源',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_session` (`session_id`),
    KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='面试报告表';
```

---

### 3.6 用户能力档案表 (t_user_profile)

```sql
CREATE TABLE `t_user_profile` (
    `id` bigint NOT NULL COMMENT '主键ID',
    `user_id` varchar(64) NOT NULL COMMENT '用户ID',
    `position_id` bigint NOT NULL COMMENT '岗位ID',
    `total_interviews` int DEFAULT 0 COMMENT '面试总次数',
    `completed_interviews` int DEFAULT 0 COMMENT '已完成面试次数',
    `total_duration` int DEFAULT 0 COMMENT '总面试时长(秒)',
    `avg_score` decimal(5,2) DEFAULT 0.00 COMMENT '平均分',
    `highest_score` decimal(5,2) DEFAULT 0.00 COMMENT '最高分',
    `skill_scores` json COMMENT '各技能得分',
    `weak_skills` json COMMENT '薄弱技能列表',
    `strong_skills` json COMMENT '优势技能列表',
    `last_interview_time` datetime DEFAULT NULL COMMENT '最近面试时间',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_position` (`user_id`, `position_id`),
    KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户能力档案表';
```

**skill_scores 格式示例：**
```json
{
  "Java基础": {"score": 75, "count": 10},
  "Spring框架": {"score": 68, "count": 8},
  "数据库": {"score": 82, "count": 12},
  "分布式": {"score": 55, "count": 5}
}
```

---

## 四、索引设计

### 4.1 索引策略

| 表名 | 索引名 | 索引类型 | 字段 | 说明 |
|------|--------|---------|------|------|
| t_position | uk_code | UNIQUE | code | 岗位编码唯一 |
| t_interview_question | idx_position_category | NORMAL | position_id, category | 按岗位和类别查询 |
| t_interview_session | uk_session | UNIQUE | session_id | 会话ID唯一 |
| t_interview_session | idx_user_time | NORMAL | user_id, start_time | 用户面试历史查询 |
| t_interview_qa | idx_session | NORMAL | session_id | 会话问答查询 |
| t_interview_report | uk_session | UNIQUE | session_id | 报告与会话一对一 |
| t_user_profile | uk_user_position | UNIQUE | user_id, position_id | 用户岗位档案唯一 |

---

## 五、数据字典

### 5.1 题目类别枚举

| 值 | 说明 |
|------|------|
| tech | 技术知识题 |
| project | 项目经历题 |
| scene | 场景设计题 |
| behavior | 行为面试题 |

### 5.2 难度等级枚举

| 值 | 说明 |
|------|------|
| 1 | 初级 |
| 2 | 中级 |
| 3 | 高级 |

### 5.3 面试模式枚举

| 值 | 说明 |
|------|------|
| free | 自由练习模式 |
| simulate | 模拟面试模式 |
| focus | 专项突破模式 |

### 5.4 会话状态枚举

| 值 | 说明 |
|------|------|
| ongoing | 进行中 |
| completed | 已完成 |
| cancelled | 已取消 |

---

## 六、初始化数据

### 6.1 岗位初始数据

```sql
INSERT INTO `t_position` (`id`, `name`, `code`, `description`, `skill_tree`, `eval_weights`, `enabled`) VALUES
(1, 'Java后端工程师', 'java_backend', '负责Java后端开发，熟悉Spring生态', 
 '{"categories":[{"name":"Java基础","skills":[{"name":"集合框架","weight":0.15},{"name":"多线程","weight":0.15},{"name":"JVM","weight":0.10}]},{"name":"框架技术","skills":[{"name":"Spring","weight":0.20},{"name":"MyBatis","weight":0.10}]},{"name":"数据库","skills":[{"name":"MySQL","weight":0.15},{"name":"Redis","weight":0.10}]},{"name":"分布式","skills":[{"name":"微服务","weight":0.05}]}]}',
 '{"tech_correctness":0.30,"knowledge_depth":0.25,"logic_rigor":0.20,"position_match":0.25}', 1),
(2, 'Web前端工程师', 'web_frontend', '负责Web前端开发，熟悉React/Vue',
 '{"categories":[{"name":"HTML/CSS","skills":[{"name":"HTML5","weight":0.10},{"name":"CSS3","weight":0.10},{"name":"响应式布局","weight":0.05}]},{"name":"JavaScript","skills":[{"name":"ES6+","weight":0.15},{"name":"TypeScript","weight":0.10}]},{"name":"框架","skills":[{"name":"React","weight":0.20},{"name":"Vue","weight":0.10}]},{"name":"工程化","skills":[{"name":"Webpack","weight":0.10},{"name":"性能优化","weight":0.10}]}]}',
 '{"tech_correctness":0.30,"knowledge_depth":0.25,"logic_rigor":0.20,"position_match":0.25}', 1);
```

---

## 七、数据库迁移脚本

完整的数据库初始化脚本见：`/resources/database/schema_faceit.sql`
