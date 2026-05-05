# Advanced Prompting Techniques

For experienced users looking to squeeze more precision and control from AI models.

---

## Temperature & Model Parameters

### **Understanding Temperature**
Temperature controls randomness in AI responses:
- **0.0:** Deterministic (same input = same output every time)
- **0.3-0.5:** Low creativity, focused answers (best for code, facts)
- **0.7:** Balanced (good for general tasks)
- **0.9-1.0:** High creativity, varied responses (brainstorming, writing)
- **1.5+:** Maximum variability (only for creative exploration)

### **When to Adjust Temperature**

| Task | Temperature | Reason |
|------|---|---|
| Code generation | 0.2 | Determinism ensures correctness |
| Debugging | 0.3-0.4 | Focused reasoning, fewer false paths |
| Brainstorming | 0.8-1.0 | Need diverse ideas |
| Writing/prose | 0.7-0.8 | Natural variation, not repetitive |
| Math/logic | 0.0-0.2 | Must be exact |
| Creative fiction | 1.0-1.5 | Maximum variety |

### **Implementation Tips**
```
# When you can't control temperature directly in chat:
"Generate 5 completely different approaches to this problem (not variations of the same idea)"
→ Simulates higher temperature

"Generate the most straightforward, minimal solution"
→ Simulates lower temperature
```

---

## Prompt Compression & Token Optimization

### **Aggressive Abbreviation**
```markdown
# ❌ Normal (longer)
"I'm working with Kubernetes and need to create a persistent volume for a PostgreSQL database. 
The volume should be at least 50GB and support read-write-many access."

# ✅ Compressed (same meaning)
"K8s PV for PostgreSQL, 50GB+, RWX access"
```

### **Structural Optimization**
Remove articles, conjunctions, connectors:
```markdown
# ❌ Full prose (more tokens)
"I would like you to help me understand how this Ansible playbook works. 
It seems to be doing something with Docker, and I'm not sure what each task does."

# ✅ Structured (fewer tokens)
"Explain each task in this Ansible playbook:
[playbook code]"
```

### **Reference Pattern**
Instead of repeating context, use references:
```markdown
# ❌ Repetitive
"In my previous message, I showed you a Bash script. That script has an issue..."

# ✅ Reference
"That script [previous message] has an issue with..."
```

### **Common Compression Patterns**

| Verbose | Compressed |
|---------|-----------|
| "Can you please provide" | "Provide" |
| "I was wondering if you could" | "Generate" |
| "In addition to that" | "Also" |
| "The reason I'm asking is" | "Context:" |
| "Let me know if you need clarification" | [just ask] |

### **When NOT to Compress**
- Security-critical instructions (be fully explicit)
- Complex architectural decisions (clarity > brevity)
- User permissions/access (never abbreviate)

---

## Multimodal Prompting

### **Including Code Files**
```markdown
# Option 1: Inline small code
"Fix this function:
```python
def process(data):
    return data.split(',')
```"

# Option 2: Reference large files
"Review the authentication module (auth.py, lines 45-120) for SQL injection vulnerabilities"

# Option 3: Describe visual code structure
"I have a 500-line Kubernetes manifest with nested ConfigMaps. 
The issue is in the volume mounting section (lines 250-350)."
```

### **Using Images Effectively**
```markdown
# ❌ Generic image request
"Help me understand this architecture diagram"

# ✅ Specific image prompting
"In this architecture diagram, explain:
1. Data flow between [service A] and [service B]
2. Where potential bottlenecks could occur
3. How to add redundancy to [component]"
```

### **Document & Screenshot Debugging**
```markdown
"Error screenshot: [include]
Expected result: [describe or reference]
Environment: [details]
Already tried: [list]

What's the most likely cause and how do I fix it?"
```

### **Multimodal Context Rules**
- Include only relevant portions of images/files
- Describe what you're seeing when image is unclear
- Reference specific sections by name or line number
- Tell the AI what to focus on

---

## Error Recovery & Hallucination Detection

### **Red Flags for Hallucination**

| Sign | Risk Level | What to Do |
|------|---|---|
| "According to [source] that doesn't exist" | 🔴 Critical | Ask for documentation link |
| "Use the `--magical-flag` option" (unconfirmed) | 🔴 Critical | Verify in official docs first |
| "This library provides [feature] that's not mentioned in docs" | 🟠 High | Check official docs/changelog |
| "Most developers do X" (without specifics) | 🟡 Medium | Ask for examples or stats |
| Syntax that looks plausible but wrong | 🔴 Critical | Test in non-prod first |

### **Recovery Strategies**

**Strategy 1: Source Verification**
```markdown
"You mentioned [claim]. Can you provide a link to the official documentation for this?"
```

**Strategy 2: Concrete Examples**
```markdown
"That approach seems wrong. Show me a real working example from:
- Official repository
- Published blog post
- StackOverflow answer with 100+ upvotes"
```

**Strategy 3: Direct Challenge**
```markdown
"I tested your code and it failed with: [error]
Walk me through what should happen at each line. 
Where did it go wrong?"
```

**Strategy 4: Sanity Check**
```markdown
"Before I run this in production, tell me:
- What are the most common failure modes?
- What edge cases might break this?
- How would I roll back if it fails?"
```

### **Fallback Pattern for Unknown Commands**
```markdown
"I'm not sure if [command] exists. 
Before I run it, verify these claims:
1. Is this a real command/flag?
2. Which tool/library provides it?
3. What version added it?
4. Show me official documentation"
```

### **When to Trust the AI**
✅ Code that you tested works  
✅ Patterns that match official documentation  
✅ Advice that contradicts and suggests alternatives  
✅ Explanations that cite specific sources  

❌ Don't trust unsourced claims  
❌ Don't assume obscure flags exist  
❌ Don't skip testing in non-prod  

---

## Output Formatting for Automation

### **Requesting Structured Output**

**JSON Format:**
```markdown
"Generate a security checklist as JSON with this structure:
{
  \"category\": \"string\",
  \"checks\": [
    {\"item\": \"string\", \"priority\": \"high|medium|low\", \"status\": \"pass|fail|n/a\"}
  ]
}"
```

**YAML Format:**
```markdown
"Output as valid YAML (no comments, plain structure):
```yaml
services:
  - name: string
    port: number
    protocol: string
```"
```

**CSV Format:**
```markdown
"Generate as CSV (headers on first line):
hostname,ip_address,last_check,status"
```

**Markdown Table:**
```markdown
"Create a comparison table with columns: Feature, Option A, Option B, Option C"
```

### **Delimiter-Based Parsing**
```markdown
"Output response in this format:

SUMMARY:
[one-line summary]

DETAILS:
[explanation]

CODE:
[code block]

NEXT_STEPS:
[numbered list]"
```

AI will follow delimiters → easy to parse programmatically.

### **Machine-Parseable Output**
```markdown
"Generate Kubernetes manifests as separate YAML blocks.
Each manifest should start with:
---
kind: [ResourceType]
---"
```

Then you can split and parse each block easily:
```bash
awk '/^---/{if(NR>1) print "\n"}1' output.yaml | grep -A 100 "^kind:"
```

### **Avoiding Markdown Formatting in Code Output**
```markdown
"Provide raw code (no markdown code blocks or backticks).
Just the code itself, ready to paste."
```

This gives you:
```
#!/bin/bash
echo "hello"
```
Instead of:
```
\`\`\`bash
echo "hello"
\`\`\`
```

---

## Breaking Down Complex Problems

### **Decomposition Strategy 1: Sequential**
Instead of asking for "complete system," break into phases:

```markdown
# ❌ Too broad
"Design a complete CI/CD pipeline"

# ✅ Sequential
"Phase 1: Build automation
- Generate a GitHub Actions workflow that:
  - Runs on push to main
  - Builds a Docker image
  - Pushes to registry
  
[IMPLEMENT & TEST FIRST]

Phase 2: Testing & Validation
[ASK NEXT]"
```

### **Decomposition Strategy 2: Layered**
Work from simple to complex:

```markdown
# Layer 1: Minimal working example
"Generate the simplest possible Kubernetes deployment for nginx"

# Layer 2: Add requirements
"Now add resource requests/limits"

# Layer 3: Production hardening
"Add liveness/readiness probes and security context"

# Layer 4: Scaling
"Add horizontal pod autoscaler"
```

### **Decomposition Strategy 3: Architectural**
Separate concerns:

```markdown
# Component 1: Data model
"Design the database schema for [use case]"

# Component 2: API layer
"Given that schema, generate REST endpoints"

# Component 3: Business logic
"Given those endpoints, implement validation"

# Component 4: Error handling
"Add error handling across all components"
```

### **When to Use Each Strategy**

| Strategy | Best For |
|----------|----------|
| Sequential | Features, deployments, infrastructure builds |
| Layered | Gradual feature addition, optimization |
| Architectural | Complex systems with multiple components |

---

## Prompt Versioning & A/B Testing

### **Testing Different Approaches**

```markdown
# Approach A: Direct
"Generate a Bash script to backup PostgreSQL"
→ Test in non-prod environment

# Approach B: Constraint-based
"Generate a Bash script to backup PostgreSQL using ONLY:
- Standard Unix tools
- No GNU extensions
- Must complete in 30 seconds"
→ Compare results

# Approach C: Role-based
"You are a DBA specializing in disaster recovery. 
Generate a PostgreSQL backup script with monitoring and recovery validation."
→ Compare results
```

### **Measuring Consistency**
For the same prompt, run 3-5 times with the same temperature:
```markdown
"Generate 3 different approaches to [problem]"
→ If responses are similar, the prompt is good
→ If responses vary wildly, refine the prompt
```

### **Scoring Responses**
Create a rubric:

| Criteria | Weight | Score |
|----------|--------|-------|
| Correctness (runs without error) | 40% | 1-10 |
| Security (follows best practices) | 30% | 1-10 |
| Readability (comments, structure) | 20% | 1-10 |
| Efficiency (minimal dependencies) | 10% | 1-10 |

Use this to objectively compare prompt variations.

---

## Domain Jargon Usage

### **When Jargon Helps**
```markdown
# ✅ Good: With jargon (assumes domain knowledge)
"Implement idempotent Ansible tasks using handlers and register variables"

# ✅ Also good: Without jargon (defines terms)
"Implement tasks that can run multiple times without causing issues. 
Use status tracking (register) and recovery mechanisms (handlers)."
```

### **Mixing Abstraction Levels**
```markdown
# ❌ Inconsistent mixing
"Implement a microservice that uses dependency injection to handle ORM queries efficiently"
→ Unclear what audience is

# ✅ Clear mixing with definitions
"For senior engineers: Implement DI pattern with ORM
For junior engineers: Separate data access from business logic, manage database objects centrally"
```

### **Defining Terms Inline**
```markdown
"Use idempotency (ensure running the task multiple times produces the same end state) 
to make the playbook safe to re-run"
```

### **Dialect/Version Specificity**
```markdown
# ❌ Vague
"How do I use containers?"

# ✅ Specific
"How do I use Docker with the docker-compose v2 syntax on Ubuntu 22.04?"
```

---

## Advanced Reasoning Techniques

### **Chain-of-Thought for Complex Problems**
```markdown
"Let's think through this step-by-step:

1. What is the current state?
2. What is the desired state?
3. What are the constraints?
4. What are the dependencies?
5. What could go wrong?
6. How do we measure success?

Now generate a solution."
```

### **Socratic Method (Ask Leading Questions)**
```markdown
"I want to understand your thinking. For each step:
- Why did you choose that approach?
- What alternatives did you consider?
- When would that alternative be better?"
```

### **Adversarial Prompting**
```markdown
"Argue against your own solution. 
What are the strongest criticisms someone could make?"
```

### **Meta-Prompting (Ask the AI to Improve the Prompt)**
```markdown
"Before you answer, tell me:
1. What assumptions are you making?
2. What additional information would make your answer better?
3. Are there any ambiguities in my request?"
```

---

## Model-Specific Advanced Techniques

### **GPT-4o Strengths**
- Excels at nuanced reasoning
- Good at explaining trade-offs
- Strong code generation
- Use longer context for complex architectures

**Prompt style for GPT-4o:**
```
"Provide a comprehensive analysis covering multiple perspectives. 
Include trade-offs and when each approach is optimal."
```

### **Claude (Anthropic)**
- Excellent at long-form content
- Better at admitting uncertainty
- Strong at refactoring and improvement suggestions

**Prompt style for Claude:**
```
"Help me improve this approach. What are the weaknesses?
What would you do differently and why?"
```

### **Local LLMs (Llama, Mistral)**
- Limited context window (usually 4K-32K)
- Need more explicit formatting
- Require more examples (few-shot)
- Perform better with task-specific prompts

**Prompt style for local LLMs:**
```
"TASK: [what to do]
INPUT: [specific example]
OUTPUT FORMAT: [expected structure]
EXAMPLE: [one working example]"
```

---

## Common Pitfalls & Solutions

| Pitfall | Problem | Solution |
|---------|---------|----------|
| **Over-prompting** | Too much context confuses the model | Keep to essentials only |
| **Under-specifying format** | Output doesn't match needs | Always specify format upfront |
| **Chaining too many requests** | Token bloat, loss of context | Start new conversation when off-topic |
| **Not validating output** | Using untested code | Always test in safe environment first |
| **Assuming model consistency** | Expecting same response every time | Set temperature appropriately, test variations |
| **Vague error reports** | Hard to debug** | Include full error, environment, steps taken |
| **Not exploiting model strengths** | Getting mediocre results | Tailor prompt to model's documented strengths |

---

## Prompt Engineering Workflow

A systematic approach to get better results:

1. **Draft:** Write initial prompt
2. **Test:** Run prompt, evaluate output (score on rubric)
3. **Analyze:** What worked? What didn't?
4. **Refine:** Adjust phrasing, add constraints, change format
5. **Validate:** Test refined prompt, compare scores
6. **Document:** Save winning prompt for reuse
7. **Iterate:** Run variations to optimize further

### **Keeping Prompt History**
```markdown
# Backup good prompts:

## Task: Generate Kubernetes deployment
Version 1 (generic): Score 6/10
Version 2 (with constraints): Score 8/10
Version 3 (role-based): Score 9/10

FINAL PROMPT [Version 3]:
"You are a Senior Kubernetes architect...
[full prompt text]"
```

---

## References & Resources

- **OpenAI Prompt Engineering:** Focus on clarity and specificity
- **Anthropic's Constitutional AI:** Understanding model behavior
- **LM Evaluation Harness:** Systematic prompt testing
- **PromptBase / PromptHub:** Shared high-quality prompts for reference
