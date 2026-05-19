# BigInt Migration Plan

Plan to gradually migrate Opal's corelib from Number (JS) to BigInt (JS) for representing Integer (Ruby).

## Current Status (Updated: 2025-12-29)

### ✅ Completed

**Compiler:**
- ✅ `bigint_integers` option implemented (default: false)
  - Enabled via option: `Opal.compile(code, bigint_integers: true)`
  - Enabled via magic comment: `# bigint_integers: true`
- ✅ Ruby Integer literals → JS BigInt (`42` → `42n`)
- ✅ Float literals preserved (`3.14` → `3.14`)
- ✅ Hex/Octal/Binary converted to decimal by parser, then to BigInt (`0xFF` → `255n`)
- ✅ JS embedded code (`%x{}`) left unchanged - uses Number (architectural decision)

**Tests:**
- ✅ 5 RSpec tests specific to bigint_integers
- ✅ Full RSpec compiler suite green (473 tests)
- ✅ Tests with bigint_integers disabled by default

**Documentation:**
- ✅ `BIGINT_MIGRATION_PLAN.md` created
- ✅ Commits organized and pushed

### ⚠️ Identified Issues

**Runtime Error with bigint_integers enabled:**
```
l.$< is not a function
at <internal:runtime/op_helpers.rb>:27:6 in `rb_lt`
```

**Cause:** Operator helpers (`rb_lt`, `rb_gt`, `rb_plus`, etc.) in `opal/runtime/op_helpers.rb` 
only check for `typeof === 'number'` and fail with BigInt.

**Impact:** With `bigint_integers: true` the runtime fails immediately at the first comparison/operation.

## Updated Strategy

### "Runtime-First" Approach

1. **Don't transform JS embedded code** - too complex and risky
2. **Runtime handles mixed types** - Number + BigInt operations
3. **Progressive migration** - file by file with magic comment

### Architectural Decision: Mixed Operations

The runtime must support operations between Number and BigInt:
- `42n + 10` → convert 10 to BigInt, then operate
- `42n < 10` → comparison works natively in JS
- `42n / 3.14` → convert BigInt to Number for division with float

## Migration Phases (Revised)

### ⏭️ Phase 1: Runtime Operator Helpers (NEXT STEP - Critical Priority)

**Files to modify:**
- `opal/runtime/op_helpers.rb` (lines 12-47)

**Required changes:**
```ruby
def self.rb_lt(l, r)
  %x{
    var l_type = typeof(l);
    var r_type = typeof(r);
    
    // Both numbers or both bigints - native comparison works
    if ((l_type === 'number' && r_type === 'number') ||
        (l_type === 'bigint' && r_type === 'bigint')) {
      return l < r;
    }
    
    // Mixed types - JavaScript handles this natively since ES2020
    if ((l_type === 'number' || l_type === 'bigint') &&
        (r_type === 'number' || r_type === 'bigint')) {
      return l < r;
    }
    
    // Fall back to Ruby method call
    return l['$<'](r);
  }
end
```

**Operators to update:**
- [x] Identified issue in `rb_lt` (less than)
- [ ] `rb_plus`, `rb_minus`, `rb_times`, `rb_divide`
- [ ] `rb_lt`, `rb_gt`, `rb_le`, `rb_ge`
- [ ] `eqeq`, `eqeqeq`, `neqeq`

**Special cases:**
- **Division with float:** `42n / 3.14` must convert BigInt → Number
- **Bitwise ops:** Already handled separately, should work
- **Modulo/Remainder:** Verify behavior with mixed types

**Tests:**
```bash
# After modifications
mise exec -- bin/rake mspec_ruby_nodejs 2>&1 | head -100
```

**Success criteria:**
- MSpec suite starts executing tests instead of crashing on startup
- We see test failures (not runtime errors)

### Phase 2: Additional Runtime Helpers (High Priority)

**Files:**
- `opal/runtime/helpers.rb` - coercion

**Changes:**
- Add helper `$is_bigint()`
- Modify `$coerce_to()` to handle BigInt
- Conversion helpers: `$to_bigint()`, `$bigint_to_number()`

### Phase 3: Corelib Number (High Priority)

**Files:**
- `opal/corelib/number.rb` (969 lines)
- `opal/corelib/numeric.rb`

**Challenges:**
- Methods with `%x{}` must handle mixed types
- `__id__` uses bitwise which works differently with BigInt
- Coercion between Integer/Float

**Not needed:**
- ❌ Add `# bigint_integers: true` to runtime files (they use Number on purpose)
- ❌ Modify all literals in `%x{}` (too risky)

### Phases 4-7: As per Original Plan

(Remain unchanged)

## JavaScript Interop Compatibility

### ✅ Works Natively

JavaScript ES2020+ handles many mixed operations:
```javascript
42n < 10        // true - comparison works
42n + 10n       // 52n - BigInt sum
Number(42n)     // 42 - explicit conversion
BigInt(42)      // 42n - explicit conversion
```

### ⚠️ Doesn't Work

```javascript
42n + 10        // TypeError: Cannot mix BigInt and other types
42n / 3.14      // TypeError: Cannot mix BigInt and other types
Math.sqrt(42n)  // TypeError: Cannot convert a BigInt value to a number
JSON.stringify({x: 42n})  // TypeError: Do not know how to serialize a BigInt
```

### 🔧 Solutions

1. **Mixed arithmetic operators** → Convert in runtime helper
2. **Math functions** → Convert to Number when needed
3. **JSON** → Custom serializer (to implement separately)

## Regression Testing

**Current baseline:**
- `bin/rake rspec` → 473 examples, 0 failures ✅
- `bin/rake mspec_ruby_nodejs` → Crashes with `l.$< is not a function` ❌

**Next milestones:**
1. MSpec suite runs without crashing
2. Identify how many tests fail (baseline)
3. Progressively reduce failures

## Success Metrics

- [ ] **P0:** Runtime operator helpers handle BigInt + Number
- [ ] **P0:** MSpec suite executes without crashing on startup  
- [ ] **P1:** RSpec suite green with bigint_integers: true
- [ ] **P1:** MSpec suite > 80% tests passing
- [ ] **P2:** All tests pass
- [ ] **P3:** Performance degradation < 20%
- [ ] **P3:** Documentation updated

## Immediate Next Steps

1. ✅ Update this plan
2. ⏭️ Implement mixed-type support in `op_helpers.rb`
3. ⏭️ Test with mspec, gather baseline failures
4. ⏭️ Prioritize fixes based on most common failures

## Developer Notes

- **Don't modify literals in `%x{}`** - runtime handles conversion
- **Always test with bigint disabled** before enabling it
- **Use `typeof l === 'bigint'`** for BigInt checks in JS
- **Remember:** BigInt doesn't have `-0`, `NaN`, `Infinity`
- **Float division:** Always converts to Number if one operand is float
