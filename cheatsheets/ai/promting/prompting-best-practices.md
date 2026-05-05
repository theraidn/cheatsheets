# AI Prompting — Best Practices & Techniques

## Core Principles

### 1. **Clarity Over Cleverness**
- **Good:** "Convert this JSON to CSV format"
- **Bad:** "Transform the aforementioned data structure into a tabular spreadsheet representation"
- Be direct and specific about what you want.

### 2. **Context is Everything**
- Provide background information upfront
- Specify your constraints, tools, and goals
- Include relevant examples or patterns you've seen work

### 3. **Iterative Refinement**
- Start broad, then narrow down based on responses
- Ask follow-up questions if results don't meet expectations
- Feedback helps the AI improve its responses

---

## Prompt Structure

### **The CLEAR Framework**

| Component | Purpose | Example |
|---|---|---|
| **Context** | Background and situation | "I'm a DevOps engineer working with Kubernetes 1.28" |
| **Learning** | What knowledge the AI should use | "Focus on production-grade security practices" |
| **Expectation** | Format and style desired | "Provide a YAML manifest and explain each section" |
| **Ask** | The specific request | "Create a StatefulSet for PostgreSQL" |
| **Refinement** | Constraints or preferences | "Use 3 replicas with persistent volumes" |

---

## Fundamental Techniques

### **Be Specific About Output Format**
```
❌ Bad: "Tell me about Docker"
✅ Good: "Give me a Dockerfile example for a Node.js app with multi-stage builds. Include comments explaining each section."
```

### **Specify the Audience/Role**
```
❌ Bad: "Explain Kubernetes networking"
✅ Good: "Explain Kubernetes networking to a Linux admin familiar with iptables but new to K8s. Use concrete examples."
```

### **Use Role-Based Prompting**
Tell the AI what expertise to use:
```
"You are a Senior DevOps Engineer with 15+ years of Kubernetes experience. 
Provide production-ready configurations following security best practices."
```

### **Give Examples of Expected Output**
```
"I want curl commands to test an API. Format like this:
# Test endpoint
curl -X GET http://api.local/health

# Response should be:
{ \"status\": \"ok\" }"
```

---

## Prompt Patterns for Different Tasks

### **Code Generation**
```markdown
**Context:** [What you're building and why]
**Language/Framework:** [Specific version if relevant]
**Requirements:** [Numbered list of must-haves]
**Constraints:** [Security, performance, style constraints]
**Example:** [Show a similar working example if available]
```

**Example:**
```
Generate a Python script that:
1. Reads a CSV file
2. Filters rows where column 'status' == 'active'
3. Outputs to a new CSV
Requirements: Use only stdlib, handle missing files gracefully
Style: Follow PEP 8, include docstrings
```

### **Debugging & Troubleshooting**
```markdown
**Error message:** [Exact error text]
**What I was trying to do:** [The goal]
**What I already tried:** [Steps taken so far]
**Environment:** [OS, version, tool versions]
```

**Example:**
```
Error: "connection refused" when running `docker run myapp`
Environment: Docker 24.0, Ubuntu 22.04
Already tried: Checking if port 3000 is in use (it's not)
Goal: Run a Node.js app in a container that listens on port 3000
```

### **Explanation & Learning**
```markdown
**What I want to understand:** [Topic or concept]
**My current level:** [Beginner/Intermediate/Advanced]
**Context:** [Where this applies in my work]
**Depth preferred:** [Quick overview / Detailed dive]
```

**Example:**
```
Explain Ansible idempotency
Current level: Beginner (familiar with basic playbooks)
Context: Building infrastructure automation, want to avoid duplicate changes
Depth: Medium - explain the concept and show 2 examples
```

---

## Common Mistakes to Avoid

### **❌ Vague Requests**
```
"How do I use Kubernetes?"
→ ✅ "I need to deploy a stateless web service to Kubernetes. 
     Show me the minimal YAML manifest and explain each section."
```

### **❌ Dumping Raw Code Without Context**
```
"This doesn't work, fix it: [100 lines of code]"
→ ✅ "This Ansible playbook fails at the 'Copy config' task with error 'Permission denied'.
     The target directory doesn't exist. How should I handle this?"
```

### **❌ Ambiguous Pronouns**
```
"It doesn't work because of that thing in the middle"
→ ✅ "The 'copy' module fails because the destination directory 
     (/etc/myapp) doesn't exist on the target host."
```

### **❌ Asking for Everything at Once**
```
"Build me a complete microservices architecture"
→ ✅ "Help me design the Docker image for my authentication service. 
     I need a Dockerfile with multi-stage builds, includes security scanning, 
     and is optimized for a Node.js app."
```

### **❌ Not Mentioning Constraints**
```
"Generate a script to back up my database"
→ ✅ "Write a Bash script that backs up a PostgreSQL database daily. 
     Constraints: No external tools besides pg_dump, keep only 7 days of backups, 
     log all operations, run via cron."
```

---

## Advanced Techniques

### **System Prompts & Personas**
Create a "system prompt" to establish the AI's behavior:
```
"You are a Senior Infrastructure Engineer. 
- Always prioritize security and best practices
- Flag anti-patterns and suggest better approaches
- Be concise but thorough
- Use real, documented tools and syntax only"
```

### **Chain-of-Thought Prompting**
Ask the AI to explain its reasoning step-by-step:
```
"Walk me through how you would debug this networking issue. 
Start with the most likely cause and explain your diagnostic steps."
```

### **Few-Shot Prompting**
Give examples of what you want:
```
Here's a good commit message:
  feat: add rate limiting to API endpoints

Here's a bad one:
  fixed stuff

Now generate 3 commit messages for these changes: [list changes]
```

### **Constraint-Based Prompting**
Set clear limitations:
```
"Provide a solution using ONLY:
- Bash (no Go, Python, etc.)
- Commands available in Alpine Linux
- No external tools beyond curl, jq, grep
- Must run in under 5 seconds"
```

---

## Token & Context Management

### **What's a Token?**
A token is roughly 4 characters of text. Context limits vary:
- **GPT-4o:** 128K tokens (~100K words)
- **Claude 3.5:** 200K tokens
- **Local LLMs:** Often 4K-32K tokens

### **Optimize for Token Efficiency**
1. **Trim unnecessary context:** Remove irrelevant code/logs
2. **Be concise:** "Delete files older than 7 days" vs lengthy explanation
3. **Use concise formatting:** Bullet lists vs prose
4. **Separate conversations:** Start a new thread for unrelated topics

### **Include Necessary Context Once**
```
# ❌ Repetitive
What ports does Kubernetes use? (asked in 3 separate messages)

# ✅ Better
In Kubernetes, these are the important ports: [list]
What are the security implications of exposing port 10250?
What's the best way to firewall port 6379?
```

---

## Model-Specific Tips

### **GPT-4o / Claude**
- Excellent at code generation and reasoning
- Can handle large contexts
- Good at explaining trade-offs
- Use detailed system prompts for consistency

### **Local LLMs (Llama, Mistral)**
- Keep prompts concise (fewer tokens)
- Be more explicit with formatting
- May need more examples (few-shot)
- Avoid extremely long code blocks

### **Specialized Models (Code models)**
- Expect code, may need extra detail for non-code requests
- Perform better with specific language tags
- May struggle with reasoning tasks

---

## Practical Examples

### **Example 1: Generate Ansible Playbook**
```markdown
**Context:** Managing 50 Ubuntu 22.04 servers, need to standardize SSH config
**Goal:** Install and configure OpenSSH with hardened settings
**Requirements:**
- Disable root login
- Disable password auth (require keys only)
- Change port to 2222
- Log all attempts

**Output format:** Single playbook file with variables, handlers, and comments
**Constraints:** Use only official modules, make it idempotent
```

**Response structure the AI should follow:**
1. Explanation of approach
2. Complete playbook with comments
3. How to run it
4. How to verify it worked
5. Security notes

### **Example 2: Debug a Performance Issue**
```markdown
**What's happening:** 
Kubernetes pods are getting OOMKilled randomly.

**Environment:**
- Kubernetes 1.28, 3-node cluster
- Node resources: 8GB RAM each
- 12 pods running (all 512Mi requests, no limits)

**What I've checked:**
- All pods are running successfully when created
- Issue appears after 2-3 days of running

**Question:** What diagnostics should I run and what likely causes it?
```

### **Example 3: Code Review Request**
```markdown
**Context:** Bash script for daily database backups to S3

**What I want:** 
- Code review for correctness and security
- Identify any edge cases I missed
- Suggest improvements
- Rate the error handling

**Constraints:**
- Must work on systems without GNU tools (BSD/Alpine)
- Should complete in under 1 minute
```

---

## Tips for Better Responses

### **Ask Clarifying Questions**
If the AI's response doesn't meet your needs:
```
"Your solution works, but can you explain why you used [approach] 
instead of [alternative]? When would the alternative be better?"
```

### **Request Alternatives**
```
"Good solution. Now show me a different approach using [tool/technique]. 
What are the trade-offs?"
```

### **Iterative Refinement**
```
"This is close, but adjust it to:
- Handle empty input gracefully
- Add progress output every 10 items
- Log failures to /var/log/myapp.log"
```

---

## Anti-Patterns to Avoid

| Pattern | Problem | Fix |
|---------|---------|-----|
| "Just make it work" | Vague, leads to suboptimal solutions | Specify requirements upfront |
| No error context | Hard to debug | Include error messages and environment details |
| Treating AI as mind-reader | "I want X" without explaining why | Explain the goal and constraints |
| Ignoring validation | Using code without testing | Always test suggestions in non-prod first |
| Asking and immediately dismissing | "Write code that [contradictory requirements]" | Clarify requirements before asking |

---

## Checklist for a Good Prompt

- [ ] **Context:** Background and situation explained
- [ ] **Goal:** What you want to achieve is clear
- [ ] **Format:** Expected output style specified
- [ ] **Constraints:** Limitations (tools, performance, security) listed
- [ ] **Examples:** Similar examples or patterns provided (if helpful)
- [ ] **Specificity:** No ambiguous pronouns or vague terms
- [ ] **Conciseness:** Prompt is as short as possible while being clear

---

## Quick Reference

### **Opening Phrases for Better Results**
- "You are a [role] with expertise in [domain]"
- "Provide a [format] that [constraint]"
- "Explain [concept] to someone who [background]"
- "Generate [item] with these requirements: [list]"
- "Debug this [what], which fails with [error]"

### **Closing Phrases for Better Results**
- "Explain your reasoning step-by-step"
- "Include comments explaining why"
- "What edge cases should I be aware of?"
- "What are the security implications?"
- "Show me two approaches and their trade-offs"

---

## Advanced Techniques & Going Deeper

For more specialized strategies, see **[advanced-prompting-techniques.md](advanced-prompting-techniques.md)** covering:
- Temperature & model parameters
- Prompt compression & token optimization
- Error recovery & hallucination detection
- Output formatting for automation
- A/B testing and systematic prompt refinement
- Advanced reasoning techniques

---

## References & Further Reading

- **OpenAI Prompt Engineering Guide:** Focus on clarity, role-based prompting
- **Anthropic's Constitution AI:** Understanding AI safety and alignment
- **Local LLM Documentation:** Model-specific quirks and best practices
