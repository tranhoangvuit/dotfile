name: "Create Student Endpoint - Complete CRUD Implementation"
description: |

## Purpose
Complete the student management system by implementing the missing CREATE student endpoint, following the established architectural patterns and naming conventions in the SaigonBus backend codebase.

## Core Principles
1. **Context is King**: Comprehensive understanding of existing patterns and conventions
2. **Validation Loops**: Full testing and linting validation cycle
3. **Information Dense**: Leverages existing codebase patterns extensively
4. **Progressive Success**: Layer-by-layer implementation with validation at each step
5. **Global rules**: Strict adherence to CLAUDE.md coding workflow

---

## Goal
Implement a complete POST /api/web/students endpoint that allows authenticated web admin users to create new student records with proper validation, error handling, and integration with the existing multi-tenant architecture.

## Why
- **Business Value**: Completes the student management CRUD operations for school administrators
- **User Impact**: Enables web admin users to add students manually instead of only through import
- **Integration**: Fills gap in existing student management workflow (currently only List, Get, Import exist)
- **Consistency**: Matches the pattern of other entities (reasons, campuses, staff, etc.) that have full CRUD

## What
Web admin users can create individual student records via POST request with proper validation, authentication, and multi-tenant isolation.

### Success Criteria
- [ ] POST /api/web/students endpoint accepts valid student data and returns 201 Created
- [ ] Validation enforces required fields and business rules  
- [ ] Student codes are unique within campus boundaries
- [ ] Multi-tenant isolation maintained (SchoolID from context)
- [ ] Error handling follows existing patterns with meaningful messages
- [ ] Integration tests cover happy path and error cases
- [ ] Passes all linting and test validations

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- url: https://echo.labstack.com/docs/binding
  why: Request binding and validation patterns for Echo framework
  
- url: https://entgo.io/docs/crud
  why: Ent ORM create operations and field validation patterns
  
- file: internal/handler/web/reason_handler.go (lines 69-84)
  why: Perfect example of Create handler pattern to mirror
  critical: Shows bind → validate → service call → response pattern
  
- file: internal/domain/service/reason_service.go (lines 24-38)
  why: Service layer implementation pattern for Create operations
  
- file: internal/infrastructure/datastore/reason_storer.go  
  why: Datastore Create implementation with Ent ORM patterns
  
- file: internal/usecase/input/reason.go (lines 26-29)
  why: Input DTO structure with validation tags
  
- file: internal/domain/dto/reason.go (lines 26-35)
  why: Datastore DTO patterns for Create operations
  
- file: internal/routes/router.go (lines 93-96)
  why: Route registration pattern for CRUD operations
  
- file: ent/schema/student.go
  why: Student entity fields and validation requirements
  critical: Shows StudentCode, SchoolID, CampusID requirements
```

### Current Codebase Context - Student Implementation Status
```bash
# EXISTING - Read Operations Only
internal/handler/web/student_handler.go     # ListStudents, GetStudent (NO CreateStudent)
internal/domain/service/student_service.go  # List, Get, Import (NO Create method)
internal/infrastructure/datastore/student_storer.go # Only bulk operations
internal/usecase/usecase.go                 # StudentService interface missing Create
internal/domain/gateway/gateway.go          # StudentStorer interface missing Create
internal/routes/router.go                   # GET /students only (NO POST route)

# MISSING - What we need to implement  
StudentCreateInput struct                   # New in input/student.go
StudentCreateOutput struct                  # New in output/student.go  
StudentCreateParams/Result structs          # New in dto/student.go
Create method in StudentStorer interface    # Add to gateway.go
Create method in StudentService interface   # Add to usecase.go
Create method implementations               # Add to storer and service
CreateStudent handler                       # Add to web handler
POST /students route                        # Add to router.go
Integration tests                           # Add to test/integration/web/
```

### Desired Codebase tree with files to be added/modified
```bash
internal/
├── usecase/
│   ├── input/student.go                    # ADD: StudentCreateInput struct  
│   ├── output/student.go                   # ADD: StudentCreateOutput struct
│   └── usecase.go                          # MODIFY: Add Create to StudentService interface
├── domain/
│   ├── dto/student.go                      # ADD: StudentCreateParams/Result structs
│   ├── gateway/gateway.go                  # MODIFY: Add Create to StudentStorer interface
│   └── service/student_service.go          # ADD: Create method implementation
├── infrastructure/datastore/
│   └── student_storer.go                   # ADD: Create method implementation
├── handler/web/
│   └── student_handler.go                  # ADD: CreateStudent handler function
└── routes/
    └── router.go                           # ADD: POST /students route registration

test/integration/web/
└── students_test.go                        # CREATE: Integration tests for student creation
```

### Known Gotchas of our codebase & Library Quirks
```go
// CRITICAL: Multi-tenant architecture requires SchoolID from context
// All student records MUST include school.ID from ExtractSchool(ctx)
school := ExtractSchool(ctx)
if school == nil {
    return nil, fmt.Errorf("school context required")
}

// CRITICAL: Echo validation requires explicit Validate() call
if err := h.Server.Validator.Validate(in); err != nil {
    return echo.NewHTTPError(http.StatusBadRequest, fmt.Errorf("CreateStudent: %w", err))
}

// CRITICAL: Student codes must be unique within campus, not globally
// Check uniqueness with campus_id AND student_code combination

// CRITICAL: Response pattern consistency 
// Success: return c.JSON(http.StatusCreated, student) // Note: 201, not 200
// Error: return echo.NewHTTPError(http.StatusXXX, fmt.Errorf("CreateStudent: %w", err))

// CRITICAL: Ent ORM Create pattern
entClient.Student.Create().
    SetSchoolID(school.ID).
    SetCampusID(params.CampusID).
    SetStudentCode(params.StudentCode).
    // ... other fields
    Save(ctx)
```

## Implementation Blueprint

### Data models and structure

Create the core data models following existing patterns for type safety and consistency.
```go
// Input layer (API contract)
type StudentCreateInput struct {
    CampusID            uuid.UUID `json:"campus_id" validate:"required"`
    StudentCode         string    `json:"student_code" validate:"required"`
    FirstName           string    `json:"first_name" validate:"required"`
    LastName            string    `json:"last_name" validate:"required"`
    Grade              string    `json:"grade"`
    Tutor              string    `json:"tutor"`
    Address            string    `json:"address"`
    MotherPhoneNumber  string    `json:"mother_phone_number"`
    FatherPhoneNumber  string    `json:"father_phone_number"`
    Note               string    `json:"note"`
}

// Output layer (API response)
type StudentCreateOutput struct {
    ID                 uuid.UUID `json:"id"`
    CampusID           uuid.UUID `json:"campus_id"`
    StudentCode        string    `json:"student_code"`
    FirstName          string    `json:"first_name"`
    LastName           string    `json:"last_name"`
    Grade              string    `json:"grade"`
    Tutor              string    `json:"tutor"`
    Address            string    `json:"address"`
    MotherPhoneNumber  string    `json:"mother_phone_number"`
    FatherPhoneNumber  string    `json:"father_phone_number"`
    Note               string    `json:"note"`
}
```

### List of tasks to be completed to fulfill the PRP in the order they should be completed

```yaml
Task 1: Add Input/Output DTOs
MODIFY internal/usecase/input/student.go:
  - ADD StudentCreateInput struct after line 21 (after StudentStationFilter)
  - FOLLOW validation pattern from input/reason.go lines 26-29
  - INCLUDE all student fields with proper validation tags

MODIFY internal/usecase/output/student.go:
  - ADD StudentCreateOutput struct after line 47 (after StudentParentOutput)
  - MIRROR structure from output/reason.go lines 32-35
  - EXCLUDE computed fields like AvatarURL, Parents, Siblings

Task 2: Add Domain DTOs  
MODIFY internal/domain/dto/student.go:
  - ADD StudentCreateParams struct after line 63 (after StudentUpdateParams)
  - ADD StudentCreateResult struct after StudentCreateParams
  - FOLLOW pattern from dto/reason.go lines 26-35
  - INCLUDE validation rules and JSON tags

Task 3: Update Gateway Interface
MODIFY internal/domain/gateway/gateway.go:
  - FIND StudentStorer interface (around line 45)
  - ADD Create method signature after BulkCreateOrUpdate method
  - FOLLOW pattern: Create(ctx context.Context, params dto.StudentCreateParams) (*dto.StudentCreateResult, error)

Task 4: Update Service Interface  
MODIFY internal/usecase/usecase.go:
  - FIND StudentService interface (around line 81)
  - ADD Create method after Import method
  - FOLLOW pattern: Create(ctx context.Context, input input.StudentCreateInput) (*output.StudentCreateOutput, error)

Task 5: Implement Datastore Create Method
MODIFY internal/infrastructure/datastore/student_storer.go:
  - ADD Create method implementation after BulkCreateOrUpdate method
  - FOLLOW pattern from reason_storer.go Create method
  - INCLUDE school context extraction and validation
  - HANDLE unique constraint violations gracefully

Task 6: Implement Service Create Method
MODIFY internal/domain/service/student_service.go:
  - ADD Create method implementation after Import method  
  - FOLLOW pattern from reason_service.go Create method
  - INCLUDE input validation and DTO mapping
  - DELEGATE to storer and map result back to output

Task 7: Add HTTP Handler
MODIFY internal/handler/web/student_handler.go:
  - ADD CreateStudent handler function after GetStudent function (around line 161)
  - FOLLOW pattern from reason_handler.go CreateReason (lines 69-84)
  - INCLUDE proper binding, validation, and error handling
  - RETURN 201 Created status on success

Task 8: Register Route
MODIFY internal/routes/router.go:
  - FIND student routes section (around line 144)
  - ADD POST route after GET routes: g.POST("/students", webHandler.CreateStudent)
  - FOLLOW pattern from reason routes (lines 93-96)

Task 9: Create Integration Tests
CREATE test/integration/web/students_test.go:
  - MIRROR pattern from test/integration/web/web_test.go
  - INCLUDE test cases for success, validation failures, duplicates
  - USE existing test helpers and fixtures
  - FOLLOW naming convention TestCreateStudent
```

### Per task pseudocode as needed added to each task

```go
// Task 5 - Datastore Implementation
func (s *studentStorer) Create(ctx context.Context, params dto.StudentCreateParams) (*dto.StudentCreateResult, error) {
    entClient := ExtractEntClient(ctx)
    school := ExtractSchool(ctx)
    
    // Validation
    if school == nil { return error }
    
    // Check uniqueness: student_code + campus_id
    existing := entClient.Student.Query().Where(
        student.CampusID(params.CampusID),
        student.StudentCode(params.StudentCode)
    ).First(ctx)
    if existing != nil { return duplicate error }
    
    // Create student with all fields
    st := entClient.Student.Create().
        SetSchoolID(school.ID).
        SetCampusID(params.CampusID).
        // ... all other fields
        Save(ctx)
    
    // Map to result DTO and return
}

// Task 6 - Service Implementation  
func (s *studentService) Create(ctx context.Context, input input.StudentCreateInput) (*output.StudentCreateOutput, error) {
    // Map input to datastore params
    params := dto.StudentCreateParams{
        CampusID: input.CampusID,
        // ... other fields
    }
    
    // Call datastore
    result := storer.Create(ctx, params)
    
    // Map result to output and return
}

// Task 7 - Handler Implementation
func (h *handler) CreateStudent(c echo.Context) error {
    ctx := c.Request().Context()
    var input input.StudentCreateInput
    
    // Bind and validate
    if err := c.Bind(&input); err != nil { return BadRequest }
    if err := h.Server.Validator.Validate(input); err != nil { return BadRequest }
    
    // Call service
    student := h.StudentService.Create(ctx, input)
    
    // Return 201 Created
    return c.JSON(http.StatusCreated, student)
}
```

### Integration Points
```yaml
DATABASE:
  - table: students (already exists)
  - constraints: "UNIQUE(campus_id, student_code)" 
  - fields: "all fields in ent/schema/student.go are available"
  
VALIDATION:
  - framework: "go-playground/validator/v10"
  - tags: "required, email validation for future fields"
  - pattern: "Bind() then Validator.Validate()"
  
AUTHENTICATION:
  - middleware: "WithJWTVerification already applied to /web routes"
  - context: "User context available, school context required"
  
MULTI-TENANT:
  - isolation: "SchoolID extracted from context via ExtractSchool()"
  - pattern: "All student records scoped to school automatically"
```

## Validation Loop

### Level 1: Syntax & Style
```bash
# Run these FIRST - fix any errors before proceeding
golangci-lint run ./...

# Expected: No errors. If errors, READ the error and fix.
# Common issues: unused imports, missing error checks, naming conventions
```

### Level 2: Unit Tests each new feature/file/function use existing test patterns
```go
// CREATE test/integration/web/students_test.go with these test cases:
func TestCreateStudent(t *testing.T) {
    tests := []struct {
        name           string
        input          input.StudentCreateInput
        expectedStatus int
        checkResponse  func(t *testing.T, resp *http.Response)
    }{
        {
            name: "Create student successfully",
            input: input.StudentCreateInput{
                CampusID:    campus.ID,
                StudentCode: "ST001",
                FirstName:   "John",
                LastName:    "Doe",
                Grade:       "Grade 1",
            },
            expectedStatus: http.StatusCreated,
            checkResponse: func(t *testing.T, resp *http.Response) {
                var student output.StudentCreateOutput
                testSuite.ResponseHelper.AssertJSONResponse(t, resp, &student)
                assert.Equal(t, "ST001", student.StudentCode)
                assert.Equal(t, "John", student.FirstName)
            },
        },
        {
            name: "Missing required field",
            input: input.StudentCreateInput{
                CampusID: campus.ID,
                // Missing StudentCode
                FirstName: "John",
                LastName:  "Doe",
            },
            expectedStatus: http.StatusBadRequest,
        },
        {
            name: "Duplicate student code",
            input: input.StudentCreateInput{
                CampusID:    campus.ID,
                StudentCode: "EXISTING001", // Already exists in fixtures
                FirstName:   "Jane",
                LastName:    "Doe",
            },
            expectedStatus: http.StatusConflict,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            resp, err := testSuite.HTTPHelper.MakePostRequest(
                testCtx,
                "/api/web/students",
                testSuite.GetAdminUserID(),
                tt.input,
            )
            require.NoError(t, err)
            testSuite.ResponseHelper.AssertStatusCode(t, resp, tt.expectedStatus)
            
            if tt.checkResponse != nil {
                tt.checkResponse(t, resp)
            }
        })
    }
}
```

```bash
# Run and iterate until passing:
go test ./test/integration/web -run TestCreateStudent -v
# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Test
```bash
# Test the endpoint manually (after tests pass)
curl -X POST http://localhost:8090/api/web/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -d '{
    "campus_id": "550e8400-e29b-41d4-a716-446655440000",
    "student_code": "ST999",
    "first_name": "Test",
    "last_name": "Student",
    "grade": "Grade 1"
  }'

# Expected: 201 Created with student data
# If error: Check logs for stack trace and validation errors
```

## Final validation Checklist
- [ ] All tests pass: `go test ./...`
- [ ] No linting errors: `golangci-lint run ./...`
- [ ] Manual endpoint test successful: `curl POST /api/web/students`
- [ ] Validation errors return meaningful messages
- [ ] Duplicate student codes handled gracefully
- [ ] School context isolation working correctly
- [ ] Integration tests cover happy path and error cases

---

## Anti-Patterns to Avoid
- ❌ Don't skip the datastore layer - always follow Handler→Service→Storer pattern
- ❌ Don't ignore unique constraints - handle duplicate student codes gracefully
- ❌ Don't bypass validation - use both struct tags AND explicit Validate() call
- ❌ Don't hardcode IDs or values - use proper context extraction for SchoolID
- ❌ Don't return 200 OK for creation - use 201 Created status
- ❌ Don't ignore error wrapping - use fmt.Errorf("CreateStudent: %w", err) pattern
- ❌ Don't test with mocks for integration tests - use real database and HTTP calls

---

## Confidence Score: 9/10

This PRP provides comprehensive context from the existing codebase patterns, includes all necessary technical details, provides executable validation steps, and covers all architectural layers. The AI agent should be able to implement this feature successfully in one pass by following the detailed patterns and validation loops provided.

The score is 9/10 (not 10/10) because some edge cases around file upload integration and parent-student relationships are not fully covered, but the core create functionality is thoroughly specified.