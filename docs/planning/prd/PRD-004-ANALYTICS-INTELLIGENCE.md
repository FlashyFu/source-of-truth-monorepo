# PRD-004: Analytics & Intelligence

**PRD Version:** 1.0.0  
**Created:** 2025-11-27  
**Owner:** Data Team  
**Status:** Active  
**Phase:** 4 of 5  
**Timeline:** Weeks 13-16

---

## 1. Overview

### 1.1 Purpose

This Product Requirements Document defines the specifications for FlashFusion's Analytics & Intelligence capabilities - the data platform that provides real-time dashboards, business intelligence reporting, predictive analytics, and operational insights.

### 1.2 Background

With automated workflows operational (Phase 3), Phase 4 focuses on extracting insights from workflow data, agent activities, and business operations. This phase transforms raw data into actionable intelligence that drives better business decisions.

### 1.3 Goals

1. **Real-Time Dashboards:** Operational visibility with <5s data latency
2. **Business Intelligence:** Automated reports with key business metrics
3. **Predictive Analytics:** Forecasting models for sales, churn, capacity
4. **Agent Performance:** Insights into AI agent efficiency and accuracy
5. **Cost Optimization:** Token usage tracking and optimization recommendations

### 1.4 Non-Goals (Out of Scope for Phase 4)

- Self-service dashboard builder (future phase)
- Advanced ML model training (specialized phase)
- External data marketplace (future product)

---

## 2. Requirements

### 2.1 Functional Requirements

#### FR-001: Real-Time Dashboard

**Priority:** P0 (Critical)  
**Status:** ○ Planned

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001.1 | Executive dashboard | KPIs, trends, alerts on single view |
| FR-001.2 | Operations dashboard | Workflow status, agent health |
| FR-001.3 | Sales dashboard | Pipeline, revenue, conversion |
| FR-001.4 | Support dashboard | Tickets, resolution, satisfaction |
| FR-001.5 | Real-time updates | <5s data refresh latency |

#### FR-002: Business Intelligence Reports

**Priority:** P0 (Critical)  
**Status:** ○ Planned

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-002.1 | Daily summary report | Auto-generated each morning |
| FR-002.2 | Weekly performance report | Trends, comparisons, insights |
| FR-002.3 | Monthly executive report | Strategic metrics, forecasts |
| FR-002.4 | Custom report builder | Filter, group, export data |
| FR-002.5 | Scheduled delivery | Email, Slack, webhook |

#### FR-003: Predictive Analytics

**Priority:** P1 (High)  
**Status:** ○ Planned

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-003.1 | Sales forecasting | 30/60/90 day revenue projections |
| FR-003.2 | Churn prediction | Identify at-risk customers |
| FR-003.3 | Capacity planning | Resource demand forecasting |
| FR-003.4 | Anomaly detection | Alert on unusual patterns |
| FR-003.5 | Trend analysis | Identify emerging patterns |

#### FR-004: Agent Performance Metrics

**Priority:** P1 (High)  
**Status:** ○ Planned

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-004.1 | Agent response time | Latency percentiles (p50/p95/p99) |
| FR-004.2 | Agent accuracy | Task success rate, error analysis |
| FR-004.3 | Agent utilization | Active time, idle time |
| FR-004.4 | Token consumption | Per agent, per task type |
| FR-004.5 | Cost per task | Total cost attribution |

#### FR-005: Data Pipeline

**Priority:** P0 (Critical)  
**Status:** ○ Planned

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-005.1 | Event ingestion | Real-time event streaming |
| FR-005.2 | Data transformation | ETL with validation |
| FR-005.3 | Data warehouse | Optimized for analytics queries |
| FR-005.4 | Data retention | Configurable retention policies |
| FR-005.5 | Data quality | Automated quality checks |

### 2.2 Non-Functional Requirements

#### NFR-001: Performance

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-001.1 | Dashboard load time | <2s | Initial page load |
| NFR-001.2 | Data refresh latency | <5s | Event to dashboard |
| NFR-001.3 | Query execution | <10s | Complex analytics query |
| NFR-001.4 | Report generation | <30s | Scheduled reports |

#### NFR-002: Scalability

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-002.1 | Events per second | 10,000+ | Peak ingestion rate |
| NFR-002.2 | Concurrent users | 100+ | Dashboard users |
| NFR-002.3 | Data volume | 1TB+ | Annual storage |
| NFR-002.4 | Query concurrency | 50+ | Simultaneous queries |

#### NFR-003: Reliability

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-003.1 | Dashboard uptime | 99.9% | Availability |
| NFR-003.2 | Data durability | 99.999% | No data loss |
| NFR-003.3 | Prediction accuracy | >80% | Model performance |

---

## 3. Technical Design

### 3.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA SOURCES                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   Workflow   │  │    Agent     │  │   Business   │  │   External   │   │
│  │   Events     │  │   Metrics    │  │   Events     │  │   APIs       │   │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │
│         │                 │                 │                 │           │
│         └─────────────────┴─────────────────┴─────────────────┘           │
│                                    │                                       │
└────────────────────────────────────┼───────────────────────────────────────┘
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INGESTION LAYER                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐   │
│  │   Event Stream   │────►│   Kafka/Redis    │────►│   Stream         │   │
│  │   Collectors     │     │   Message Bus    │     │   Processor      │   │
│  └──────────────────┘     └──────────────────┘     └────────┬─────────┘   │
│                                                              │             │
└──────────────────────────────────────────────────────────────┼─────────────┘
                                                               │
                                                               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         STORAGE LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐   │
│  │   Time-Series DB │     │   Data Warehouse │     │   Object Store   │   │
│  │   (TimescaleDB)  │     │   (PostgreSQL)   │     │   (S3/MinIO)     │   │
│  └────────┬─────────┘     └────────┬─────────┘     └────────┬─────────┘   │
│           │                        │                        │             │
│           └────────────────────────┴────────────────────────┘             │
│                                    │                                       │
└────────────────────────────────────┼───────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ANALYTICS LAYER                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐   │
│  │   Query Engine   │     │   ML Models      │     │   Report         │   │
│  │   (Cube.js)      │     │   (Python/SKL)   │     │   Generator      │   │
│  └────────┬─────────┘     └────────┬─────────┘     └────────┬─────────┘   │
│           │                        │                        │             │
│           └────────────────────────┴────────────────────────┘             │
│                                    │                                       │
└────────────────────────────────────┼───────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐   │
│  │   Dashboard UI   │     │   Report Portal  │     │   API/Webhooks   │   │
│  │   (Next.js)      │     │   (PDF/Email)    │     │   (REST)         │   │
│  └──────────────────┘     └──────────────────┘     └──────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Data Models

#### 3.2.1 Workflow Events

```typescript
interface WorkflowEvent {
  id: string;
  timestamp: Date;
  eventType: 'workflow_started' | 'step_completed' | 'workflow_completed' | 'workflow_failed';
  
  workflow: {
    id: string;
    name: string;
    version: string;
  };
  
  execution: {
    id: string;
    startTime: Date;
    endTime?: Date;
    status: string;
  };
  
  step?: {
    id: string;
    name: string;
    duration: number;
    result: 'success' | 'failure' | 'skipped';
  };
  
  context: {
    customerId?: string;
    orderId?: string;
    userId?: string;
  };
  
  metadata: Record<string, unknown>;
}
```

#### 3.2.2 Agent Metrics

```typescript
interface AgentMetric {
  id: string;
  timestamp: Date;
  
  agent: {
    id: string;
    name: string;
    version: string;
  };
  
  request: {
    id: string;
    action: string;
    startTime: Date;
    endTime: Date;
    duration: number;
  };
  
  result: {
    success: boolean;
    errorCode?: string;
    errorMessage?: string;
  };
  
  tokens: {
    input: number;
    output: number;
    total: number;
    cost: number;
  };
  
  context: {
    workflowId?: string;
    stepId?: string;
    userId?: string;
  };
}
```

#### 3.2.3 Business Metrics

```typescript
interface BusinessMetric {
  id: string;
  timestamp: Date;
  metricType: string;
  
  dimensions: {
    region?: string;
    product?: string;
    channel?: string;
    segment?: string;
  };
  
  measures: {
    value: number;
    count?: number;
    sum?: number;
    min?: number;
    max?: number;
    average?: number;
  };
  
  period: {
    start: Date;
    end: Date;
    granularity: 'minute' | 'hour' | 'day' | 'week' | 'month';
  };
}
```

### 3.3 Dashboard Specifications

#### 3.3.1 Executive Dashboard

```typescript
interface ExecutiveDashboard {
  sections: [
    {
      id: 'key-metrics',
      title: 'Key Performance Indicators',
      layout: 'grid-4',
      widgets: [
        {
          type: 'stat-card',
          metric: 'revenue_mtd',
          comparison: 'previous_month',
          trend: 'up' | 'down' | 'flat',
        },
        {
          type: 'stat-card',
          metric: 'active_customers',
          comparison: 'previous_month',
        },
        {
          type: 'stat-card',
          metric: 'workflow_completion_rate',
          comparison: 'previous_week',
        },
        {
          type: 'stat-card',
          metric: 'agent_success_rate',
          comparison: 'previous_day',
        },
      ],
    },
    {
      id: 'revenue-trends',
      title: 'Revenue Trends',
      layout: 'full-width',
      widgets: [
        {
          type: 'line-chart',
          metrics: ['revenue', 'forecast'],
          period: 'last_90_days',
          granularity: 'day',
        },
      ],
    },
    {
      id: 'operations-overview',
      title: 'Operations Overview',
      layout: 'grid-2',
      widgets: [
        {
          type: 'donut-chart',
          metric: 'workflow_by_status',
        },
        {
          type: 'bar-chart',
          metric: 'agent_utilization',
          dimensions: ['agent_name'],
        },
      ],
    },
  ],
  
  refresh: {
    interval: 30000, // 30 seconds
    mode: 'auto' | 'manual',
  },
  
  filters: {
    dateRange: { type: 'date-range', default: 'last_30_days' },
    region: { type: 'multi-select', options: 'dynamic' },
  },
};
```

#### 3.3.2 Operations Dashboard

```typescript
interface OperationsDashboard {
  sections: [
    {
      id: 'real-time-status',
      title: 'Real-Time Status',
      widgets: [
        {
          type: 'status-grid',
          items: [
            { name: 'Workflow Engine', source: 'health/workflow-engine' },
            { name: 'Agent Registry', source: 'health/agent-registry' },
            { name: 'Context Store', source: 'health/context-store' },
            { name: 'Event Bus', source: 'health/event-bus' },
          ],
        },
      ],
    },
    {
      id: 'active-workflows',
      title: 'Active Workflows',
      widgets: [
        {
          type: 'live-table',
          source: 'workflows/active',
          columns: ['id', 'name', 'step', 'duration', 'status'],
          sortBy: 'startTime',
          limit: 20,
        },
      ],
    },
    {
      id: 'agent-performance',
      title: 'Agent Performance',
      widgets: [
        {
          type: 'heatmap',
          metric: 'agent_latency',
          dimensions: ['agent', 'hour'],
        },
        {
          type: 'line-chart',
          metrics: ['requests_per_second', 'error_rate'],
          period: 'last_hour',
          granularity: 'minute',
        },
      ],
    },
    {
      id: 'alerts',
      title: 'Active Alerts',
      widgets: [
        {
          type: 'alert-list',
          source: 'alerts/active',
          severity: ['critical', 'warning'],
        },
      ],
    },
  ],
  
  refresh: {
    interval: 5000, // 5 seconds
    mode: 'auto',
  },
};
```

### 3.4 Predictive Models

#### 3.4.1 Sales Forecasting Model

```python
# models/sales_forecast.py
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.model_selection import TimeSeriesSplit
from datetime import datetime, timedelta

class SalesForecastModel:
    """30/60/90 day revenue forecasting model."""
    
    def __init__(self):
        self.model = GradientBoostingRegressor(
            n_estimators=100,
            max_depth=5,
            learning_rate=0.1,
            loss='huber'
        )
        self.feature_columns = [
            'day_of_week',
            'month',
            'quarter',
            'is_holiday',
            'lag_7_days',
            'lag_30_days',
            'rolling_mean_7',
            'rolling_mean_30',
            'trend'
        ]
    
    def prepare_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Extract time series features."""
        df = df.copy()
        df['day_of_week'] = df['date'].dt.dayofweek
        df['month'] = df['date'].dt.month
        df['quarter'] = df['date'].dt.quarter
        df['is_holiday'] = df['date'].isin(self.holidays)
        df['lag_7_days'] = df['revenue'].shift(7)
        df['lag_30_days'] = df['revenue'].shift(30)
        df['rolling_mean_7'] = df['revenue'].rolling(7).mean()
        df['rolling_mean_30'] = df['revenue'].rolling(30).mean()
        df['trend'] = range(len(df))
        return df.dropna()
    
    def train(self, historical_data: pd.DataFrame):
        """Train model on historical revenue data."""
        df = self.prepare_features(historical_data)
        X = df[self.feature_columns]
        y = df['revenue']
        
        # Time series cross-validation
        tscv = TimeSeriesSplit(n_splits=5)
        for train_idx, val_idx in tscv.split(X):
            X_train, X_val = X.iloc[train_idx], X.iloc[val_idx]
            y_train, y_val = y.iloc[train_idx], y.iloc[val_idx]
            self.model.fit(X_train, y_train)
        
        # Final fit on all data
        self.model.fit(X, y)
    
    def forecast(self, periods: int = 90) -> pd.DataFrame:
        """Generate revenue forecast for next N days."""
        last_data = self.get_recent_data(30)
        forecasts = []
        
        for i in range(periods):
            next_date = datetime.now() + timedelta(days=i)
            features = self.prepare_forecast_features(next_date, last_data)
            prediction = self.model.predict([features])[0]
            
            forecasts.append({
                'date': next_date,
                'predicted_revenue': prediction,
                'confidence_lower': prediction * 0.9,
                'confidence_upper': prediction * 1.1,
            })
            
            last_data = self.update_history(last_data, prediction)
        
        return pd.DataFrame(forecasts)
```

#### 3.4.2 Customer Churn Model

```python
# models/churn_prediction.py
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler

class ChurnPredictionModel:
    """Predict customers at risk of churning."""
    
    def __init__(self):
        self.model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            class_weight='balanced'
        )
        self.scaler = StandardScaler()
        self.feature_columns = [
            'days_since_last_activity',
            'activity_frequency_30d',
            'support_tickets_30d',
            'login_frequency_30d',
            'feature_adoption_score',
            'nps_score',
            'contract_days_remaining',
            'payment_failures_90d',
            'workflow_usage_30d',
            'agent_interactions_30d'
        ]
    
    def train(self, customer_data: pd.DataFrame):
        """Train on historical customer data with churn labels."""
        X = self.scaler.fit_transform(customer_data[self.feature_columns])
        y = customer_data['churned']
        self.model.fit(X, y)
    
    def predict(self, current_customers: pd.DataFrame) -> pd.DataFrame:
        """Predict churn probability for current customers."""
        X = self.scaler.transform(current_customers[self.feature_columns])
        probabilities = self.model.predict_proba(X)[:, 1]
        
        results = current_customers[['customer_id', 'customer_name']].copy()
        results['churn_probability'] = probabilities
        results['risk_level'] = pd.cut(
            probabilities,
            bins=[0, 0.3, 0.6, 1.0],
            labels=['Low', 'Medium', 'High']
        )
        
        return results.sort_values('churn_probability', ascending=False)
    
    def get_at_risk_customers(self, threshold: float = 0.6) -> pd.DataFrame:
        """Get customers above churn risk threshold."""
        predictions = self.predict(self.get_current_customers())
        return predictions[predictions['churn_probability'] >= threshold]
```

### 3.5 Technology Stack

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| Dashboard UI | Next.js | 14+ | SSR, React, TypeScript |
| Charting | Recharts | 2.x | React-native, customizable |
| Query Engine | Cube.js | 0.35+ | Semantic layer, caching |
| Time-Series DB | TimescaleDB | 2.x | PostgreSQL extension, fast |
| Data Warehouse | PostgreSQL | 15+ | Reliable, powerful |
| Stream Processing | Redis Streams | 7+ | Real-time, simple |
| ML Runtime | Python | 3.11+ | sklearn, pandas |
| Object Storage | MinIO | Latest | S3-compatible, self-hosted |

---

## 4. Dashboard Designs

### 4.1 Executive Dashboard Wireframe

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ FlashFusion Executive Dashboard                     [Filters] [▼ Last 30d] │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  ┌───────────┐ │
│  │  REVENUE MTD   │  │   CUSTOMERS    │  │  WORKFLOWS     │  │  AGENTS   │ │
│  │    $124.5K     │  │      342       │  │    98.2%       │  │   99.1%   │ │
│  │    ▲ 12.3%     │  │    ▲ 8.1%      │  │    ▲ 2.1%      │  │   ▲ 0.5%  │ │
│  └────────────────┘  └────────────────┘  └────────────────┘  └───────────┘ │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Revenue Trend & Forecast                                           │   │
│  │                                              ╭──────────────────╮   │   │
│  │   150K ─┤                               ___╱│    Forecast      │   │   │
│  │         │                           ___╱    │    ± Confidence  │   │   │
│  │   100K ─┤                      ____╱        ╰──────────────────╯   │   │
│  │         │                 ____╱                                    │   │
│  │    50K ─┤            ____╱                                         │   │
│  │         │       ____╱                                              │   │
│  │      0 ─┴──────────────────────────────────────────────────────    │   │
│  │         Sep        Oct        Nov        Dec        Jan        Feb │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌────────────────────────────────┐  ┌────────────────────────────────┐   │
│  │  Workflow Status               │  │  Agent Utilization            │   │
│  │  ┌───────────────────┐         │  │                               │   │
│  │  │    ╭──────╮       │         │  │  Orchestrator  ████████░░ 82% │   │
│  │  │   ╱ 95.2% ╲       │         │  │  Financial     ██████░░░░ 67% │   │
│  │  │  │ Success │      │         │  │  Support       █████░░░░░ 54% │   │
│  │  │   ╲       ╱       │         │  │  Security      ████░░░░░░ 41% │   │
│  │  │    ╰──────╯       │         │  │  DevOps        ███░░░░░░░ 35% │   │
│  │  │  ● Pending  3.2%  │         │  │                               │   │
│  │  │  ● Failed   1.6%  │         │  │                               │   │
│  │  └───────────────────┘         │  │                               │   │
│  └────────────────────────────────┘  └────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Operations Dashboard Wireframe

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ FlashFusion Operations                              [Live] [Refresh: 5s] ● │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  System Health                                                      │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │   │
│  │  │   Engine    │ │  Registry   │ │  Context    │ │  Event Bus  │   │   │
│  │  │   ● OK      │ │   ● OK      │ │   ● OK      │ │   ● OK      │   │   │
│  │  │   42ms p95  │ │   12ms p95  │ │   8ms p95   │ │   3ms p95   │   │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌──────────────────────────────────┐  ┌──────────────────────────────┐   │
│  │  Active Workflows (23)           │  │  Agent Performance           │   │
│  │  ┌──────────────────────────────┐│  │                              │   │
│  │  │ ID      │ Name    │ Step │ ⏱ ││  │  Requests/sec: 45.2         │   │
│  │  ├─────────┼─────────┼──────┼───┤│  │  ┌────────────────────────┐ │   │
│  │  │ exec-12 │ Onboard │ 3/5  │ 2s││  │  │     ╭╮  ╭╮  ╭╮        │ │   │
│  │  │ exec-11 │ Invoice │ 2/4  │ 5s││  │  │ ___╱  ╲╱  ╲╱  ╲___    │ │   │
│  │  │ exec-10 │ Support │ 1/3  │ 1s││  │  └────────────────────────┘ │   │
│  │  │ exec-09 │ Onboard │ 4/5  │ 8s││  │                              │   │
│  │  │ exec-08 │ Publish │ 2/6  │ 3s││  │  Error Rate: 0.3%           │   │
│  │  └──────────────────────────────┘│  │  ┌────────────────────────┐ │   │
│  └──────────────────────────────────┘  │  │ ___________________    │ │   │
│                                        │  └────────────────────────┘ │   │
│  ┌──────────────────────────────────┐  └──────────────────────────────┘   │
│  │  Active Alerts (2)               │                                     │
│  │  ┌──────────────────────────────┐│                                     │
│  │  │ 🔴 CRITICAL: Agent timeout   ││                                     │
│  │  │    12:34:56 - Financial Agent││                                     │
│  │  │ 🟡 WARNING: High latency     ││                                     │
│  │  │    12:30:12 - Workflow Engine││                                     │
│  │  └──────────────────────────────┘│                                     │
│  └──────────────────────────────────┘                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. User Stories

### 5.1 Executive User Stories

#### US-001: View Business KPIs

**As an** executive  
**I want to** see key business metrics at a glance  
**So that** I can understand company performance

**Acceptance Criteria:**
- [ ] Revenue, customers, workflow rate visible
- [ ] Comparison to previous period shown
- [ ] Trend indicators (up/down arrows)
- [ ] Drill-down to details available

#### US-002: View Revenue Forecast

**As an** executive  
**I want to** see predicted revenue for next 90 days  
**So that** I can plan budgets and resources

**Acceptance Criteria:**
- [ ] Forecast line with confidence interval
- [ ] Interactive date range selection
- [ ] Assumption breakdown available
- [ ] Export to spreadsheet

### 5.2 Operations User Stories

#### US-003: Monitor System Health

**As an** operations engineer  
**I want to** see real-time system status  
**So that** I can identify and resolve issues quickly

**Acceptance Criteria:**
- [ ] All services shown with status
- [ ] Latency metrics displayed
- [ ] Alerts prominently visible
- [ ] Auto-refresh every 5 seconds

#### US-004: Track Workflow Execution

**As an** operations engineer  
**I want to** see all active workflow executions  
**So that** I can monitor processing and identify stuck workflows

**Acceptance Criteria:**
- [ ] List of active workflows
- [ ] Current step and duration shown
- [ ] Click to view details
- [ ] Filter by workflow type

### 5.3 Business User Stories

#### US-005: Generate Reports

**As a** business analyst  
**I want to** generate custom reports  
**So that** I can share insights with stakeholders

**Acceptance Criteria:**
- [ ] Select metrics and dimensions
- [ ] Apply filters
- [ ] Choose date range
- [ ] Export PDF/Excel

#### US-006: Identify At-Risk Customers

**As a** customer success manager  
**I want to** see customers at risk of churning  
**So that** I can take proactive action

**Acceptance Criteria:**
- [ ] List sorted by churn probability
- [ ] Risk factors shown
- [ ] Contact history available
- [ ] Action recommendations

---

## 6. API Specifications

### 6.1 Dashboard API

```typescript
// api/dashboards.ts

/**
 * Get dashboard configuration
 */
GET /api/dashboards/:dashboardId
Response: {
  dashboard: Dashboard;
  permissions: Permissions;
}

/**
 * Get dashboard data
 */
POST /api/dashboards/:dashboardId/data
Request: {
  filters: Record<string, unknown>;
  dateRange: { start: Date; end: Date };
  granularity: 'minute' | 'hour' | 'day' | 'week' | 'month';
}
Response: {
  widgets: WidgetData[];
  lastUpdated: Date;
}

/**
 * Subscribe to real-time updates
 */
WS /api/dashboards/:dashboardId/stream
Message: {
  widgetId: string;
  data: unknown;
  timestamp: Date;
}
```

### 6.2 Analytics API

```typescript
// api/analytics.ts

/**
 * Query metrics
 */
POST /api/analytics/query
Request: {
  metrics: string[];
  dimensions?: string[];
  filters?: Record<string, unknown>;
  dateRange: { start: Date; end: Date };
  granularity?: string;
  limit?: number;
}
Response: {
  data: Record<string, unknown>[];
  metadata: {
    total: number;
    executionTime: number;
  };
}

/**
 * Get forecasts
 */
GET /api/analytics/forecasts/:forecastType
Request: {
  periods: number;
  confidence: number;
}
Response: {
  forecasts: Forecast[];
  model: {
    name: string;
    accuracy: number;
    lastTrained: Date;
  };
}

/**
 * Get anomalies
 */
GET /api/analytics/anomalies
Request: {
  metrics: string[];
  dateRange: { start: Date; end: Date };
  sensitivity: 'low' | 'medium' | 'high';
}
Response: {
  anomalies: Anomaly[];
}
```

### 6.3 Reports API

```typescript
// api/reports.ts

/**
 * List reports
 */
GET /api/reports
Response: {
  reports: Report[];
}

/**
 * Generate report
 */
POST /api/reports/:reportId/generate
Request: {
  format: 'pdf' | 'excel' | 'csv';
  filters?: Record<string, unknown>;
  dateRange: { start: Date; end: Date };
}
Response: {
  jobId: string;
  status: 'queued';
  estimatedTime: number;
}

/**
 * Get report status
 */
GET /api/reports/jobs/:jobId
Response: {
  status: 'queued' | 'processing' | 'completed' | 'failed';
  downloadUrl?: string;
  error?: string;
}

/**
 * Schedule report
 */
POST /api/reports/:reportId/schedule
Request: {
  cron: string;
  format: string;
  recipients: string[];
}
Response: {
  scheduleId: string;
}
```

---

## 7. Testing Strategy

### 7.1 Dashboard Tests

```typescript
// tests/integration/dashboard.test.ts
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { DashboardAPI } from '@flashfusion/analytics';

describe('Dashboard API', () => {
  let api: DashboardAPI;

  before(async () => {
    api = await DashboardAPI.connect();
  });

  it('should return dashboard configuration', async () => {
    const result = await api.getDashboard('executive');
    assert.ok(result.dashboard);
    assert.ok(result.dashboard.sections.length > 0);
  });

  it('should return dashboard data within latency SLA', async () => {
    const start = Date.now();
    const result = await api.getDashboardData('executive', {
      dateRange: { start: new Date('2025-01-01'), end: new Date() },
    });
    const duration = Date.now() - start;

    assert.ok(result.widgets.length > 0);
    assert.ok(duration < 2000, `Dashboard load took ${duration}ms, expected <2000ms`);
  });

  it('should stream real-time updates', async (t) => {
    const updates: unknown[] = [];
    const stream = api.streamDashboard('operations');

    stream.on('data', (data) => updates.push(data));

    await new Promise((resolve) => setTimeout(resolve, 10000));
    stream.close();

    assert.ok(updates.length > 0, 'Should receive real-time updates');
  });
});
```

### 7.2 Model Tests

```python
# tests/test_models.py
import pytest
import pandas as pd
from models.sales_forecast import SalesForecastModel
from models.churn_prediction import ChurnPredictionModel

class TestSalesForecastModel:
    def test_model_training(self, historical_revenue_data):
        model = SalesForecastModel()
        model.train(historical_revenue_data)
        
        assert model.model is not None
        assert hasattr(model, 'feature_columns')
    
    def test_forecast_generation(self, trained_model):
        forecasts = trained_model.forecast(periods=30)
        
        assert len(forecasts) == 30
        assert 'predicted_revenue' in forecasts.columns
        assert 'confidence_lower' in forecasts.columns
        assert 'confidence_upper' in forecasts.columns
    
    def test_forecast_values_reasonable(self, trained_model, historical_revenue_data):
        forecasts = trained_model.forecast(periods=30)
        avg_historical = historical_revenue_data['revenue'].mean()
        
        # Forecasts should be within 50% of historical average
        assert all(forecasts['predicted_revenue'] > avg_historical * 0.5)
        assert all(forecasts['predicted_revenue'] < avg_historical * 1.5)


class TestChurnPredictionModel:
    def test_model_training(self, customer_data):
        model = ChurnPredictionModel()
        model.train(customer_data)
        
        assert model.model is not None
    
    def test_prediction_output(self, trained_churn_model, current_customers):
        predictions = trained_churn_model.predict(current_customers)
        
        assert 'churn_probability' in predictions.columns
        assert 'risk_level' in predictions.columns
        assert all(predictions['churn_probability'] >= 0)
        assert all(predictions['churn_probability'] <= 1)
    
    def test_at_risk_customers(self, trained_churn_model):
        at_risk = trained_churn_model.get_at_risk_customers(threshold=0.6)
        
        assert all(at_risk['churn_probability'] >= 0.6)
```

---

## 8. Deployment Strategy

### 8.1 Dashboard Deployment

```yaml
# k8s/analytics/dashboard-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: analytics-dashboard
  namespace: analytics
spec:
  replicas: 3
  selector:
    matchLabels:
      app: analytics-dashboard
  template:
    spec:
      containers:
        - name: dashboard
          image: flashfusion/analytics-dashboard:1.0.0
          ports:
            - containerPort: 3000
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: analytics-secrets
                  key: database-url
            - name: CUBEJS_API_SECRET
              valueFrom:
                secretKeyRef:
                  name: analytics-secrets
                  key: cubejs-secret
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: analytics-dashboard-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: analytics-dashboard
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### 8.2 Data Pipeline Deployment

```yaml
# k8s/analytics/data-pipeline-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-pipeline
  namespace: analytics
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: processor
          image: flashfusion/data-pipeline:1.0.0
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
          env:
            - name: REDIS_URL
              value: "redis://event-bus:6379"
            - name: TIMESCALE_URL
              valueFrom:
                secretKeyRef:
                  name: analytics-secrets
                  key: timescale-url
```

---

## 9. Rollout Plan

### 9.1 Week 13: Data Pipeline

- [ ] Deploy TimescaleDB
- [ ] Implement event collectors
- [ ] Create stream processor
- [ ] Configure data retention

### 9.2 Week 14: Core Dashboards

- [ ] Deploy Cube.js semantic layer
- [ ] Implement Executive Dashboard
- [ ] Implement Operations Dashboard
- [ ] Configure real-time streaming

### 9.3 Week 15: Predictive Models

- [ ] Deploy ML model serving
- [ ] Train sales forecasting model
- [ ] Train churn prediction model
- [ ] Integrate predictions into dashboard

### 9.4 Week 16: Reports & Launch

- [ ] Implement report generator
- [ ] Configure scheduled reports
- [ ] Deploy monitoring & alerts
- [ ] Documentation complete

---

## 10. Success Criteria

### 10.1 Definition of Done

- [ ] Dashboards loading in <2s
- [ ] Real-time data latency <5s
- [ ] 3+ dashboards operational
- [ ] 2+ predictive models deployed
- [ ] Scheduled reports functional

### 10.2 Acceptance Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Dashboard load time | <2s | TBD | ○ |
| Data refresh latency | <5s | TBD | ○ |
| Prediction accuracy | >80% | TBD | ○ |
| Report generation | <30s | TBD | ○ |

---

## 11. Appendix

### 11.1 Glossary

| Term | Definition |
|------|------------|
| KPI | Key Performance Indicator |
| ETL | Extract, Transform, Load |
| Time-Series DB | Database optimized for time-stamped data |
| Semantic Layer | Abstraction for consistent metric definitions |

### 11.2 References

- [Cube.js Documentation](https://cube.dev/docs)
- [TimescaleDB Documentation](https://docs.timescale.com)
- [Recharts Documentation](https://recharts.org)

### 11.3 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-11-27 | Data Team | Initial PRD |

---

**Document Owner:** Data Team  
**Next Review:** 2026-01-22  
**Approval Status:** Pending
