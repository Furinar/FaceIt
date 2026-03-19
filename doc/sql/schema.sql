-- FaceIt 数据库建表脚本
-- 数据库：PostgreSQL 15+
-- 创建时间：2026-03-19

-- ============================================
-- 1. 创建更新时间戳函数
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================
-- 2. 用户表 (users)
-- ============================================

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    real_name VARCHAR(50),
    school VARCHAR(100),
    major VARCHAR(100),
    grade VARCHAR(20),
    target_position VARCHAR(50),
    job_status VARCHAR(20) DEFAULT 'preparing',
    avatar_url VARCHAR(255),
    status SMALLINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 用户表索引
CREATE INDEX idx_users_target_position ON users(target_position);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 用户表触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 用户表注释
COMMENT ON TABLE users IS '用户表';
COMMENT ON COLUMN users.id IS '用户ID';
COMMENT ON COLUMN users.username IS '用户名';
COMMENT ON COLUMN users.password IS '密码（BCrypt加密）';
COMMENT ON COLUMN users.email IS '邮箱';
COMMENT ON COLUMN users.phone IS '手机号';
COMMENT ON COLUMN users.real_name IS '真实姓名';
COMMENT ON COLUMN users.school IS '学校';
COMMENT ON COLUMN users.major IS '专业';
COMMENT ON COLUMN users.grade IS '年级';
COMMENT ON COLUMN users.target_position IS '意向岗位：java_backend/web_frontend';
COMMENT ON COLUMN users.job_status IS '求职阶段：preparing/interviewing/offered';
COMMENT ON COLUMN users.avatar_url IS '头像URL';
COMMENT ON COLUMN users.status IS '账号状态：0-禁用，1-正常';

-- ============================================
-- 3. 面试会话表 (interview_sessions)
-- ============================================

CREATE TABLE interview_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    job_position VARCHAR(50) NOT NULL,
    interview_mode VARCHAR(20) NOT NULL,
    duration_minutes INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    actual_duration INTEGER,
    total_questions INTEGER DEFAULT 0,
    total_answers INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 面试会话表索引
CREATE INDEX idx_interview_sessions_user_id ON interview_sessions(user_id, created_at);
CREATE INDEX idx_interview_sessions_job_position ON interview_sessions(job_position);
CREATE INDEX idx_interview_sessions_status ON interview_sessions(status);

-- 面试会话表触发器
CREATE TRIGGER update_interview_sessions_updated_at BEFORE UPDATE ON interview_sessions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 面试会话表注释
COMMENT ON TABLE interview_sessions IS '面试会话表';
COMMENT ON COLUMN interview_sessions.id IS '会话ID';
COMMENT ON COLUMN interview_sessions.user_id IS '用户ID';
COMMENT ON COLUMN interview_sessions.job_position IS '面试岗位：java_backend/web_frontend';
COMMENT ON COLUMN interview_sessions.interview_mode IS '面试模式：basic/full/special';
COMMENT ON COLUMN interview_sessions.duration_minutes IS '面试时长（分钟）';
COMMENT ON COLUMN interview_sessions.status IS '会话状态：pending/in_progress/completed/interrupted';
COMMENT ON COLUMN interview_sessions.start_time IS '开始时间';
COMMENT ON COLUMN interview_sessions.end_time IS '结束时间';
COMMENT ON COLUMN interview_sessions.actual_duration IS '实际时长（秒）';
COMMENT ON COLUMN interview_sessions.total_questions IS '总提问数';
COMMENT ON COLUMN interview_sessions.total_answers IS '总回答数';

-- ============================================
-- 4. 对话记录表 (conversation_messages)
-- ============================================

CREATE TABLE conversation_messages (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,
    message_type VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    audio_url VARCHAR(255),
    audio_duration INTEGER,
    stage VARCHAR(50),
    sequence INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_message_session FOREIGN KEY (session_id) REFERENCES interview_sessions(id) ON DELETE CASCADE
);

-- 对话记录表索引
CREATE INDEX idx_conversation_messages_session_id ON conversation_messages(session_id, sequence);
CREATE INDEX idx_conversation_messages_role ON conversation_messages(role);
CREATE INDEX idx_conversation_messages_stage ON conversation_messages(stage);

-- 对话记录表注释
COMMENT ON TABLE conversation_messages IS '对话记录表';
COMMENT ON COLUMN conversation_messages.id IS '消息ID';
COMMENT ON COLUMN conversation_messages.session_id IS '会话ID';
COMMENT ON COLUMN conversation_messages.role IS '角色：interviewer/candidate';
COMMENT ON COLUMN conversation_messages.message_type IS '消息类型：text/audio';
COMMENT ON COLUMN conversation_messages.content IS '消息内容（文本）';
COMMENT ON COLUMN conversation_messages.audio_url IS '音频文件URL';
COMMENT ON COLUMN conversation_messages.audio_duration IS '音频时长（秒）';
COMMENT ON COLUMN conversation_messages.stage IS '面试阶段：self_intro/tech/project/scenario/behavior';
COMMENT ON COLUMN conversation_messages.sequence IS '消息序号';

-- ============================================
-- 5. 评估报告表 (evaluation_reports)
-- ============================================

CREATE TABLE evaluation_reports (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,
    overall_score DECIMAL(5,2) NOT NULL,
    grade VARCHAR(5) NOT NULL,
    technical_accuracy DECIMAL(5,2),
    logical_rigor DECIMAL(5,2),
    job_matching DECIMAL(5,2),
    expression_ability DECIMAL(5,2),
    confidence DECIMAL(5,2),
    strengths JSONB,
    weaknesses JSONB,
    summary TEXT,
    suggestions JSONB,
    radar_chart_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_report_session FOREIGN KEY (session_id) REFERENCES interview_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 评估报告表索引
CREATE INDEX idx_evaluation_reports_user_id ON evaluation_reports(user_id, created_at);
CREATE INDEX idx_evaluation_reports_overall_score ON evaluation_reports(overall_score);
CREATE INDEX idx_evaluation_reports_grade ON evaluation_reports(grade);

-- 评估报告表注释
COMMENT ON TABLE evaluation_reports IS '评估报告表';
COMMENT ON COLUMN evaluation_reports.id IS '报告ID';
COMMENT ON COLUMN evaluation_reports.session_id IS '会话ID';
COMMENT ON COLUMN evaluation_reports.user_id IS '用户ID';
COMMENT ON COLUMN evaluation_reports.overall_score IS '综合得分（0-100）';
COMMENT ON COLUMN evaluation_reports.grade IS '评级：S/A/B/C/D';
COMMENT ON COLUMN evaluation_reports.technical_accuracy IS '技术正确性得分';
COMMENT ON COLUMN evaluation_reports.logical_rigor IS '逻辑严谨性得分';
COMMENT ON COLUMN evaluation_reports.job_matching IS '岗位匹配度得分';
COMMENT ON COLUMN evaluation_reports.expression_ability IS '表达能力得分';
COMMENT ON COLUMN evaluation_reports.confidence IS '自信度得分';
COMMENT ON COLUMN evaluation_reports.strengths IS '优势亮点（JSON数组）';
COMMENT ON COLUMN evaluation_reports.weaknesses IS '薄弱环节（JSON数组）';
COMMENT ON COLUMN evaluation_reports.summary IS '总结分析';
COMMENT ON COLUMN evaluation_reports.suggestions IS '改进建议（JSON数组）';
COMMENT ON COLUMN evaluation_reports.radar_chart_data IS '雷达图数据（JSON）';

-- ============================================
-- 6. 逐题评价表 (question_evaluations)
-- ============================================

CREATE TABLE question_evaluations (
    id BIGSERIAL PRIMARY KEY,
    report_id BIGINT NOT NULL,
    question_message_id BIGINT NOT NULL,
    answer_message_id BIGINT NOT NULL,
    question_content TEXT NOT NULL,
    answer_content TEXT NOT NULL,
    score DECIMAL(5,2),
    correctness VARCHAR(20),
    highlights JSONB,
    issues JSONB,
    improvement TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evaluation_report FOREIGN KEY (report_id) REFERENCES evaluation_reports(id) ON DELETE CASCADE,
    CONSTRAINT fk_evaluation_question FOREIGN KEY (question_message_id) REFERENCES conversation_messages(id) ON DELETE CASCADE,
    CONSTRAINT fk_evaluation_answer FOREIGN KEY (answer_message_id) REFERENCES conversation_messages(id) ON DELETE CASCADE
);

-- 逐题评价表索引
CREATE INDEX idx_question_evaluations_report_id ON question_evaluations(report_id);
CREATE INDEX idx_question_evaluations_correctness ON question_evaluations(correctness);

-- 逐题评价表注释
COMMENT ON TABLE question_evaluations IS '逐题评价表';
COMMENT ON COLUMN question_evaluations.id IS '评价ID';
COMMENT ON COLUMN question_evaluations.report_id IS '报告ID';
COMMENT ON COLUMN question_evaluations.question_message_id IS '问题消息ID';
COMMENT ON COLUMN question_evaluations.answer_message_id IS '回答消息ID';
COMMENT ON COLUMN question_evaluations.question_content IS '问题内容';
COMMENT ON COLUMN question_evaluations.answer_content IS '回答内容';
COMMENT ON COLUMN question_evaluations.score IS '单题得分（0-100）';
COMMENT ON COLUMN question_evaluations.correctness IS '正确性：correct/partial/incorrect';
COMMENT ON COLUMN question_evaluations.highlights IS '亮点（JSON数组）';
COMMENT ON COLUMN question_evaluations.issues IS '问题点（JSON数组）';
COMMENT ON COLUMN question_evaluations.improvement IS '改进方向';

-- ============================================
-- 7. 知识库文档表 (knowledge_documents)
-- ============================================

CREATE TABLE knowledge_documents (
    id BIGSERIAL PRIMARY KEY,
    job_position VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    file_path VARCHAR(255),
    tags VARCHAR(255),
    difficulty VARCHAR(20),
    status SMALLINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 知识库文档表索引
CREATE INDEX idx_knowledge_documents_job_position ON knowledge_documents(job_position, category);
CREATE INDEX idx_knowledge_documents_difficulty ON knowledge_documents(difficulty);
CREATE INDEX idx_knowledge_documents_status ON knowledge_documents(status);

-- 知识库文档表触发器
CREATE TRIGGER update_knowledge_documents_updated_at BEFORE UPDATE ON knowledge_documents
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 知识库文档表注释
COMMENT ON TABLE knowledge_documents IS '知识库文档表';
COMMENT ON COLUMN knowledge_documents.id IS '文档ID';
COMMENT ON COLUMN knowledge_documents.job_position IS '所属岗位';
COMMENT ON COLUMN knowledge_documents.category IS '分类：tech_stack/question/answer';
COMMENT ON COLUMN knowledge_documents.title IS '文档标题';
COMMENT ON COLUMN knowledge_documents.content IS '文档内容';
COMMENT ON COLUMN knowledge_documents.file_path IS '文件路径';
COMMENT ON COLUMN knowledge_documents.tags IS '标签（逗号分隔）';
COMMENT ON COLUMN knowledge_documents.difficulty IS '难度：basic/intermediate/advanced';
COMMENT ON COLUMN knowledge_documents.status IS '状态：0-禁用，1-启用';

-- ============================================
-- 8. 知识库切片表 (knowledge_chunks)
-- ============================================

CREATE TABLE knowledge_chunks (
    id BIGSERIAL PRIMARY KEY,
    document_id BIGINT NOT NULL,
    chunk_index INTEGER NOT NULL,
    content TEXT NOT NULL,
    vector_id VARCHAR(100) UNIQUE,
    token_count INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chunk_document FOREIGN KEY (document_id) REFERENCES knowledge_documents(id) ON DELETE CASCADE
);

-- 知识库切片表索引
CREATE INDEX idx_knowledge_chunks_document_id ON knowledge_chunks(document_id, chunk_index);
CREATE INDEX idx_knowledge_chunks_vector_id ON knowledge_chunks(vector_id);

-- 知识库切片表注释
COMMENT ON TABLE knowledge_chunks IS '知识库切片表';
COMMENT ON COLUMN knowledge_chunks.id IS '切片ID';
COMMENT ON COLUMN knowledge_chunks.document_id IS '文档ID';
COMMENT ON COLUMN knowledge_chunks.chunk_index IS '切片序号';
COMMENT ON COLUMN knowledge_chunks.content IS '切片内容';
COMMENT ON COLUMN knowledge_chunks.vector_id IS '向量数据库中的ID';
COMMENT ON COLUMN knowledge_chunks.token_count IS 'Token数量';

-- ============================================
-- 9. 能力成长记录表 (ability_growth_records)
-- ============================================

CREATE TABLE ability_growth_records (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    report_id BIGINT NOT NULL,
    job_position VARCHAR(50) NOT NULL,
    overall_score DECIMAL(5,2) NOT NULL,
    technical_accuracy DECIMAL(5,2),
    logical_rigor DECIMAL(5,2),
    job_matching DECIMAL(5,2),
    expression_ability DECIMAL(5,2),
    confidence DECIMAL(5,2),
    interview_count INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_growth_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_growth_report FOREIGN KEY (report_id) REFERENCES evaluation_reports(id) ON DELETE CASCADE
);

-- 能力成长记录表索引
CREATE INDEX idx_ability_growth_records_user_id ON ability_growth_records(user_id, created_at);
CREATE INDEX idx_ability_growth_records_job_position ON ability_growth_records(job_position);

-- 能力成长记录表注释
COMMENT ON TABLE ability_growth_records IS '能力成长记录表';
COMMENT ON COLUMN ability_growth_records.id IS '记录ID';
COMMENT ON COLUMN ability_growth_records.user_id IS '用户ID';
COMMENT ON COLUMN ability_growth_records.report_id IS '报告ID';
COMMENT ON COLUMN ability_growth_records.job_position IS '岗位';
COMMENT ON COLUMN ability_growth_records.overall_score IS '综合得分';
COMMENT ON COLUMN ability_growth_records.technical_accuracy IS '技术正确性';
COMMENT ON COLUMN ability_growth_records.logical_rigor IS '逻辑严谨性';
COMMENT ON COLUMN ability_growth_records.job_matching IS '岗位匹配度';
COMMENT ON COLUMN ability_growth_records.expression_ability IS '表达能力';
COMMENT ON COLUMN ability_growth_records.confidence IS '自信度';
COMMENT ON COLUMN ability_growth_records.interview_count IS '累计面试次数';

-- ============================================
-- 10. 推荐练习表 (practice_recommendations)
-- ============================================

CREATE TABLE practice_recommendations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    report_id BIGINT NOT NULL,
    recommendation_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    resource_url VARCHAR(255),
    priority INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    CONSTRAINT fk_recommendation_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_recommendation_report FOREIGN KEY (report_id) REFERENCES evaluation_reports(id) ON DELETE CASCADE
);

-- 推荐练习表索引
CREATE INDEX idx_practice_recommendations_user_id ON practice_recommendations(user_id, status);
CREATE INDEX idx_practice_recommendations_report_id ON practice_recommendations(report_id);
CREATE INDEX idx_practice_recommendations_priority ON practice_recommendations(priority DESC);

-- 推荐练习表注释
COMMENT ON TABLE practice_recommendations IS '推荐练习表';
COMMENT ON COLUMN practice_recommendations.id IS '推荐ID';
COMMENT ON COLUMN practice_recommendations.user_id IS '用户ID';
COMMENT ON COLUMN practice_recommendations.report_id IS '报告ID';
COMMENT ON COLUMN practice_recommendations.recommendation_type IS '推荐类型：knowledge/question/skill';
COMMENT ON COLUMN practice_recommendations.title IS '推荐标题';
COMMENT ON COLUMN practice_recommendations.description IS '推荐描述';
COMMENT ON COLUMN practice_recommendations.resource_url IS '资源链接';
COMMENT ON COLUMN practice_recommendations.priority IS '优先级（数字越大越优先）';
COMMENT ON COLUMN practice_recommendations.status IS '状态：pending/completed/ignored';
COMMENT ON COLUMN practice_recommendations.completed_at IS '完成时间';

-- ============================================
-- 11. 系统配置表 (system_configs)
-- ============================================

CREATE TABLE system_configs (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 系统配置表触发器
CREATE TRIGGER update_system_configs_updated_at BEFORE UPDATE ON system_configs
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 系统配置表注释
COMMENT ON TABLE system_configs IS '系统配置表';
COMMENT ON COLUMN system_configs.id IS '配置ID';
COMMENT ON COLUMN system_configs.config_key IS '配置键';
COMMENT ON COLUMN system_configs.config_value IS '配置值';
COMMENT ON COLUMN system_configs.description IS '配置描述';

-- ============================================
-- 12. 初始化系统配置数据
-- ============================================

INSERT INTO system_configs (config_key, config_value, description) VALUES
('interview.max_duration', '60', '面试最大时长（分钟）'),
('interview.default_duration', '30', '面试默认时长（分钟）'),
('evaluation.dimensions', '{"technical_accuracy":0.30,"logical_rigor":0.25,"job_matching":0.20,"expression_ability":0.15,"confidence":0.10}', '评估维度权重配置'),
('evaluation.grade_threshold', '{"S":90,"A":80,"B":70,"C":60,"D":0}', '评级分数阈值'),
('ai.model', 'glm-4', '默认AI模型'),
('ai.temperature', '0.7', 'AI生成温度参数'),
('ai.max_tokens', '2048', 'AI生成最大Token数'),
('rag.chunk_size', '500', 'RAG文档切片大小'),
('rag.top_k', '5', 'RAG检索返回数量'),
('rate_limit.login', '10', '登录接口限流（次/分钟）'),
('rate_limit.interview', '60', '面试对话接口限流（次/分钟）'),
('rate_limit.upload', '5', '文件上传接口限流（次/分钟）');

-- ============================================
-- 13. 创建视图
-- ============================================

-- 用户面试统计视图
CREATE VIEW v_user_interview_stats AS
SELECT 
    u.id AS user_id,
    u.username,
    u.target_position,
    COUNT(DISTINCT isess.id) AS total_interviews,
    COUNT(DISTINCT CASE WHEN isess.status = 'completed' THEN isess.id END) AS completed_interviews,
    AVG(er.overall_score) AS avg_score,
    MAX(er.overall_score) AS max_score,
    MAX(er.created_at) AS last_interview_time
FROM users u
LEFT JOIN interview_sessions isess ON u.id = isess.user_id
LEFT JOIN evaluation_reports er ON isess.id = er.session_id
GROUP BY u.id, u.username, u.target_position;

-- 面试会话详情视图
CREATE VIEW v_interview_detail AS
SELECT 
    isess.id AS session_id,
    isess.user_id,
    u.username,
    u.real_name,
    isess.job_position,
    isess.interview_mode,
    isess.duration_minutes,
    isess.status,
    isess.start_time,
    isess.end_time,
    isess.actual_duration,
    isess.total_questions,
    isess.total_answers,
    er.overall_score,
    er.grade
FROM interview_sessions isess
JOIN users u ON isess.user_id = u.id
LEFT JOIN evaluation_reports er ON isess.id = er.session_id;

-- 知识库统计视图
CREATE VIEW v_knowledge_stats AS
SELECT 
    job_position,
    category,
    difficulty,
    COUNT(*) AS document_count,
    SUM(LENGTH(content)) AS total_content_length
FROM knowledge_documents
WHERE status = 1
GROUP BY job_position, category, difficulty;

-- ============================================
-- 14. 创建枚举类型检查约束
-- ============================================

-- 用户表约束
ALTER TABLE users ADD CONSTRAINT chk_users_job_status 
    CHECK (job_status IN ('preparing', 'interviewing', 'offered'));
ALTER TABLE users ADD CONSTRAINT chk_users_status 
    CHECK (status IN (0, 1));

-- 面试会话表约束
ALTER TABLE interview_sessions ADD CONSTRAINT chk_interview_sessions_job_position 
    CHECK (job_position IN ('java_backend', 'web_frontend'));
ALTER TABLE interview_sessions ADD CONSTRAINT chk_interview_sessions_interview_mode 
    CHECK (interview_mode IN ('basic', 'full', 'special'));
ALTER TABLE interview_sessions ADD CONSTRAINT chk_interview_sessions_status 
    CHECK (status IN ('pending', 'in_progress', 'completed', 'interrupted'));
ALTER TABLE interview_sessions ADD CONSTRAINT chk_interview_sessions_duration 
    CHECK (duration_minutes IN (10, 20, 30));

-- 对话记录表约束
ALTER TABLE conversation_messages ADD CONSTRAINT chk_conversation_messages_role 
    CHECK (role IN ('interviewer', 'candidate'));
ALTER TABLE conversation_messages ADD CONSTRAINT chk_conversation_messages_message_type 
    CHECK (message_type IN ('text', 'audio'));
ALTER TABLE conversation_messages ADD CONSTRAINT chk_conversation_messages_stage 
    CHECK (stage IS NULL OR stage IN ('self_intro', 'tech', 'project', 'scenario', 'behavior'));

-- 评估报告表约束
ALTER TABLE evaluation_reports ADD CONSTRAINT chk_evaluation_reports_grade 
    CHECK (grade IN ('S', 'A', 'B', 'C', 'D'));
ALTER TABLE evaluation_reports ADD CONSTRAINT chk_evaluation_reports_score 
    CHECK (overall_score >= 0 AND overall_score <= 100);

-- 逐题评价表约束
ALTER TABLE question_evaluations ADD CONSTRAINT chk_question_evaluations_correctness 
    CHECK (correctness IS NULL OR correctness IN ('correct', 'partial', 'incorrect'));
ALTER TABLE question_evaluations ADD CONSTRAINT chk_question_evaluations_score 
    CHECK (score IS NULL OR (score >= 0 AND score <= 100));

-- 知识库文档表约束
ALTER TABLE knowledge_documents ADD CONSTRAINT chk_knowledge_documents_category 
    CHECK (category IN ('tech_stack', 'question', 'answer', 'guide'));
ALTER TABLE knowledge_documents ADD CONSTRAINT chk_knowledge_documents_difficulty 
    CHECK (difficulty IS NULL OR difficulty IN ('basic', 'intermediate', 'advanced'));
ALTER TABLE knowledge_documents ADD CONSTRAINT chk_knowledge_documents_status 
    CHECK (status IN (0, 1));

-- 推荐练习表约束
ALTER TABLE practice_recommendations ADD CONSTRAINT chk_practice_recommendations_type 
    CHECK (recommendation_type IN ('knowledge', 'question', 'skill'));
ALTER TABLE practice_recommendations ADD CONSTRAINT chk_practice_recommendations_status 
    CHECK (status IN ('pending', 'completed', 'ignored'));

-- ============================================
-- 11. 岗位配置表 (job_positions)
-- ============================================

CREATE TABLE job_positions (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    tech_stack JSONB,
    exam_points JSONB,
    dimensions JSONB,
    interview_modes JSONB,
    status SMALLINT DEFAULT 1,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_job_positions_status ON job_positions(status, sort_order);

CREATE TRIGGER update_job_positions_updated_at BEFORE UPDATE ON job_positions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE job_positions IS '岗位配置表';
COMMENT ON COLUMN job_positions.id IS '岗位ID';
COMMENT ON COLUMN job_positions.code IS '岗位代码';
COMMENT ON COLUMN job_positions.name IS '岗位名称';
COMMENT ON COLUMN job_positions.description IS '岗位描述';
COMMENT ON COLUMN job_positions.icon IS '图标标识';
COMMENT ON COLUMN job_positions.tech_stack IS '技术栈清单（JSON数组）';
COMMENT ON COLUMN job_positions.exam_points IS '面试考点（JSON数组）';
COMMENT ON COLUMN job_positions.dimensions IS '评估维度配置（JSON数组）';
COMMENT ON COLUMN job_positions.interview_modes IS '面试模式配置（JSON数组）';
COMMENT ON COLUMN job_positions.status IS '状态：0-禁用，1-启用';
COMMENT ON COLUMN job_positions.sort_order IS '排序序号';

-- ============================================
-- 12. 练习计划表 (practice_plans)
-- ============================================

CREATE TABLE practice_plans (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    job_position VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    plan_data JSONB NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    progress INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_plan_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_practice_plans_user_id ON practice_plans(user_id, status);
CREATE INDEX idx_practice_plans_job_position ON practice_plans(job_position);

CREATE TRIGGER update_practice_plans_updated_at BEFORE UPDATE ON practice_plans
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE practice_plans IS '练习计划表';
COMMENT ON COLUMN practice_plans.id IS '计划ID';
COMMENT ON COLUMN practice_plans.user_id IS '用户ID';
COMMENT ON COLUMN practice_plans.job_position IS '岗位代码';
COMMENT ON COLUMN practice_plans.title IS '计划标题';
COMMENT ON COLUMN practice_plans.description IS '计划描述';
COMMENT ON COLUMN practice_plans.plan_data IS '计划详情（JSON）';
COMMENT ON COLUMN practice_plans.start_date IS '开始日期';
COMMENT ON COLUMN practice_plans.end_date IS '结束日期';
COMMENT ON COLUMN practice_plans.status IS '状态：active/completed/cancelled';
COMMENT ON COLUMN practice_plans.progress IS '进度百分比';

-- ============================================
-- 13. 错题记录表 (mistake_records)
-- ============================================

CREATE TABLE mistake_records (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    job_position VARCHAR(50) NOT NULL,
    question_content TEXT NOT NULL,
    correct_answer TEXT,
    user_answer TEXT,
    issues JSONB,
    source_report_id BIGINT,
    review_count INTEGER DEFAULT 0,
    last_review_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mistake_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_mistake_report FOREIGN KEY (source_report_id) REFERENCES evaluation_reports(id) ON DELETE SET NULL
);

CREATE INDEX idx_mistake_records_user_id ON mistake_records(user_id, job_position);
CREATE INDEX idx_mistake_records_source_report_id ON mistake_records(source_report_id);

COMMENT ON TABLE mistake_records IS '错题记录表';
COMMENT ON COLUMN mistake_records.id IS '记录ID';
COMMENT ON COLUMN mistake_records.user_id IS '用户ID';
COMMENT ON COLUMN mistake_records.job_position IS '岗位代码';
COMMENT ON COLUMN mistake_records.question_content IS '问题内容';
COMMENT ON COLUMN mistake_records.correct_answer IS '正确答案';
COMMENT ON COLUMN mistake_records.user_answer IS '用户回答';
COMMENT ON COLUMN mistake_records.issues IS '问题点（JSON数组）';
COMMENT ON COLUMN mistake_records.source_report_id IS '来源报告ID';
COMMENT ON COLUMN mistake_records.review_count IS '复习次数';
COMMENT ON COLUMN mistake_records.last_review_at IS '最后复习时间';
COMMENT ON COLUMN mistake_records.notes IS '复习笔记';

-- ============================================
-- 14. 帮助文章表 (help_articles)
-- ============================================

CREATE TABLE help_articles (
    id BIGSERIAL PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    summary VARCHAR(500),
    content TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    status SMALLINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_help_articles_category ON help_articles(category, sort_order);
CREATE INDEX idx_help_articles_status ON help_articles(status);

CREATE TRIGGER update_help_articles_updated_at BEFORE UPDATE ON help_articles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE help_articles IS '帮助文章表';
COMMENT ON COLUMN help_articles.id IS '文章ID';
COMMENT ON COLUMN help_articles.category IS '分类：tutorial/tips/faq';
COMMENT ON COLUMN help_articles.title IS '文章标题';
COMMENT ON COLUMN help_articles.summary IS '文章摘要';
COMMENT ON COLUMN help_articles.content IS '文章内容（Markdown）';
COMMENT ON COLUMN help_articles.sort_order IS '排序序号';
COMMENT ON COLUMN help_articles.status IS '状态：0-禁用，1-启用';

-- ============================================
-- 15. 初始化岗位配置数据
-- ============================================

INSERT INTO job_positions (code, name, description, icon, tech_stack, exam_points, dimensions, interview_modes, status, sort_order) VALUES
('java_backend', 'Java 后端开发', '负责后端服务开发、数据库设计、接口开发等', 'java',
 '[{"name":"Java","level":"核心"},{"name":"Spring Boot","level":"核心"},{"name":"MySQL","level":"核心"},{"name":"Redis","level":"重要"},{"name":"Spring Cloud","level":"重要"},{"name":"Docker","level":"了解"}]',
 '["Java 基础与集合","并发编程与 JVM","Spring 框架原理","数据库设计与优化","分布式系统设计","项目经验与架构"]',
 '[{"name":"技术正确性","weight":0.30,"description":"知识点是否准确"},{"name":"逻辑严谨性","weight":0.25,"description":"表达是否有条理"},{"name":"岗位匹配度","weight":0.20,"description":"与岗位要求契合度"},{"name":"表达能力","weight":0.15,"description":"语速、清晰度、流畅度"},{"name":"自信度","weight":0.10,"description":"语音情感分析"}]',
 '[{"code":"basic","name":"基础模式","description":"基础题+简单流程"},{"code":"full","name":"全真模式","description":"完整企业面试流程+压力追问"},{"code":"special","name":"专项训练","description":"技术题/项目题/行为题"}]',
 1, 1),
('web_frontend', 'Web 前端开发', '负责前端界面开发、用户交互、性能优化等', 'frontend',
 '[{"name":"JavaScript","level":"核心"},{"name":"Vue/React","level":"核心"},{"name":"CSS","level":"核心"},{"name":"TypeScript","level":"重要"},{"name":"Webpack","level":"重要"},{"name":"Node.js","level":"了解"}]',
 '["JavaScript 核心","Vue/React 框架","CSS 布局与动画","浏览器原理","性能优化","项目经验与架构"]',
 '[{"name":"技术正确性","weight":0.30,"description":"知识点是否准确"},{"name":"逻辑严谨性","weight":0.25,"description":"表达是否有条理"},{"name":"岗位匹配度","weight":0.20,"description":"与岗位要求契合度"},{"name":"表达能力","weight":0.15,"description":"语速、清晰度、流畅度"},{"name":"自信度","weight":0.10,"description":"语音情感分析"}]',
 '[{"code":"basic","name":"基础模式","description":"基础题+简单流程"},{"code":"full","name":"全真模式","description":"完整企业面试流程+压力追问"},{"code":"special","name":"专项训练","description":"技术题/项目题/行为题"}]',
 1, 2);

-- ============================================
-- 16. 初始化帮助文章数据
-- ============================================

INSERT INTO help_articles (category, title, summary, content, sort_order, status) VALUES
('tutorial', '如何开始你的第一次模拟面试', '本教程将指导你完成第一次模拟面试的全过程',
 '# 如何开始你的第一次模拟面试\n\n## 1. 选择岗位\n\n首先，你需要选择一个面试岗位。目前支持 Java 后端开发和 Web 前端开发两个岗位。\n\n## 2. 选择面试模式\n\n- **基础模式**：适合初次体验，题目较简单，流程较简化\n- **全真模式**：模拟真实企业面试，包含完整流程和压力追问\n- **专项训练**：针对特定类型题目进行强化练习\n\n## 3. 设置面试时长\n\n可选择 10 分钟、20 分钟或 30 分钟。建议初次体验选择 10 分钟。\n\n## 4. 开始面试\n\n点击"开始面试"后，AI 面试官会引导你完成整个面试流程。\n\n## 5. 查看评估报告\n\n面试结束后，系统会自动生成详细的评估报告，帮助你了解自己的优势和不足。',
 1, 1),
('tips', '面试回答技巧', '掌握这些技巧，让你的面试回答更加出色',
 '# 面试回答技巧\n\n## 1. STAR 法则\n\n回答行为面试题时，使用 STAR 法则：\n- **S (Situation)**：描述情境\n- **T (Task)**：说明任务\n- **A (Action)**：详述行动\n- **R (Result)**：展示结果\n\n## 2. 结构化回答\n\n回答技术问题时，采用"总-分-总"结构：\n- 先给出核心观点\n- 再展开详细说明\n- 最后总结归纳\n\n## 3. 诚实面对\n\n遇到不会的问题，诚实说明，但可以展示学习态度和思考过程。',
 2, 1),
('faq', '常见问题解答', '关于平台使用的常见问题',
 '# 常见问题解答\n\n## Q: 面试过程中可以暂停吗？\n\nA: 可以，面试过程中点击"暂停"按钮即可暂停计时。暂停期间不会影响评估结果。\n\n## Q: 语音识别支持哪些格式？\n\nA: 目前支持 WAV、MP3、WebM 格式的音频文件。\n\n## Q: 评估报告可以保存多久？\n\nA: 所有评估报告会永久保存，你可以随时在"个人中心"查看历史记录。\n\n## Q: 如何提高面试表现？\n\nA: 建议多进行模拟面试，关注评估报告中的薄弱环节，并在"能力提升中心"进行针对性练习。',
 3, 1);

-- ============================================
-- 17. 新增约束
-- ============================================

-- 岗位配置表约束
ALTER TABLE job_positions ADD CONSTRAINT chk_job_positions_status 
    CHECK (status IN (0, 1));

-- 练习计划表约束
ALTER TABLE practice_plans ADD CONSTRAINT chk_practice_plans_status 
    CHECK (status IN ('active', 'completed', 'cancelled'));
ALTER TABLE practice_plans ADD CONSTRAINT chk_practice_plans_progress 
    CHECK (progress >= 0 AND progress <= 100);

-- 错题记录表约束
ALTER TABLE mistake_records ADD CONSTRAINT chk_mistake_records_review_count 
    CHECK (review_count >= 0);

-- 帮助文章表约束
ALTER TABLE help_articles ADD CONSTRAINT chk_help_articles_category 
    CHECK (category IN ('tutorial', 'tips', 'faq'));
ALTER TABLE help_articles ADD CONSTRAINT chk_help_articles_status 
    CHECK (status IN (0, 1));

-- ============================================
-- 完成
-- ============================================

-- 输出完成信息
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'FaceIt 数据库初始化完成！';
    RAISE NOTICE '创建表数量：14';
    RAISE NOTICE '创建视图数量：3';
    RAISE NOTICE '初始化配置数量：12';
    RAISE NOTICE '初始化岗位数量：2';
    RAISE NOTICE '初始化帮助文章数量：3';
    RAISE NOTICE '========================================';
END $$;
