## 📋 Before You Start

**If you want to develop in dbt complete the setup first!** Follow the instructions in [../README.md](../README.md) to:
- Install dependencies
- Set up your dbt environment
- Load the seed data
- Verify everything is working

Once setup is complete, return here for the task requirements.

---

## 🎯 Scenario

You are part of the analytics engineering team at a company that provides a podcast streaming app with millions of users. Your task is to create transformations on interaction logs to create clean, well-modelled data sets that enable analytics around user engagement and episode performance.


## 📦 Provided Data

You receive raw event data in the form of event logs with key fields including:
- **event_type**: "play", "pause", "seek", "complete"
- **user_id**
- **episode_id**
- **timestamp**
- **duration**: only for "play" and "complete" events

You also have two reference files:
- **users** (user_id, signup_date, country)
- **episodes** (episode_id, podcast_id, title, release_date, duration_seconds)

---

## 🗂 Part 1: Data Modelling

Design a relational schema that:
- Provides a clean, analytics-ready layer for interaction events.
- Supports use cases such as:
  - Top episodes by completion
  - Average listen-through rate
  - Retention and engagement by user cohort

**Deliverable:**
- ERD or DDL statements (SQL or dbt schema.yml / models.sql structure)
- Commentary on any key modelling decisions made

## ⚙ Part 2: Transformations

Build transformations that:
- Clean and normalise the events:
  - Parse event_type (play, pause, seek, complete)
  - Handle missing or malformed timestamps
  - Filter out events with no user or episode ID
- Include some data quality validation (e.g. null checks, timestamp range checks)
- Populate the target schema you defined in Part 1
- Note: You can load the provided data manually into a database to facilitate

**Deliverables:**
- dbt models (preferred) or SQL scripts for the transformations
- Data quality tests
- Brief note on how these transformations could be orchestrated

## 📈 Part 3: Analysis

Write SQL for:
- The top 10 most completed episodes in the most recent 7 days in the dataset
- Average listen-through rate (completion duration/episode duration) by country
- Number of distinct users who listened to 3+ different episodes in one day
- Optional: Any other insightful analysis you might want to provide

---

## ✅ Submission Requirements

Please submit a repo (or zipped folder) containing:

### 1️⃣ Modelling Layer
- ERD *or* DDL (SQL/dbt models)
- Brief notes explaining key modelling decisions

### 2️⃣ Transformations
- dbt models (preferred) or SQL scripts  
- Basic data quality tests  
- Short note describing your orchestration approach

### 3️⃣ Analysis
- SQL queries answering the required questions  
- Optional additional insights (if included)

### 4️⃣ README
- Clear instructions to run your solution  
- Assumptions made  
- Explanation of your modelling and transformation approach  

---

> **Note:** The dataset is mock-generated. We are primarily assessing your modelling approach, SQL quality, structure, and analytical thinking, not the “correctness” of the data itself.

