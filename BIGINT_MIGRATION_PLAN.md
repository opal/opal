# BigInt Migration Plan

Piano per migrare gradualmente la corelib di Opal da Number (JS) a BigInt (JS) per rappresentare Integer (Ruby).

## Stato Attuale (Aggiornato: 2025-12-29)

### ✅ Completato

**Compilatore:**
- ✅ Opzione `bigint_integers` implementata (default: false)
  - Abilitabile via option: `Opal.compile(code, bigint_integers: true)`
  - Abilitabile via magic comment: `# bigint_integers: true`
- ✅ Integer literals Ruby → BigInt JS (`42` → `42n`)
- ✅ Float literals preservati (`3.14` → `3.14`)
- ✅ Hex/Octal/Binary convertiti a decimale dal parser, poi a BigInt (`0xFF` → `255n`)
- ✅ JS embedded (`%x{}`) lasciato invariato - usa Number (decisione architetturale)

**Test:**
- ✅ 5 test RSpec specifici per bigint_integers
- ✅ Suite RSpec compiler completa verde (473 test)
- ✅ Test con bigint_integers disabled per default

**Documentazione:**
- ✅ `BIGINT_MIGRATION_PLAN.md` creato
- ✅ Commits organizzati e pushati

### ⚠️ Problemi Identificati

**Errore Runtime con bigint_integers abilitato:**
```
l.$< is not a function
at <internal:runtime/op_helpers.rb>:27:6 in `rb_lt`
```

**Causa:** Gli operator helpers (`rb_lt`, `rb_gt`, `rb_plus`, etc.) in `opal/runtime/op_helpers.rb` 
controllano solo `typeof === 'number'` e falliscono con BigInt.

**Impatto:** Con `bigint_integers: true` il runtime fallisce immediatamente al primo confronto/operazione.

## Strategia Aggiornata

### Approccio "Runtime-First"

1. **Non trasformiamo JS embedded** - troppo complesso e rischioso
2. **Il runtime gestisce tipi misti** - Number + BigInt operazioni
3. **Migrazione progressiva** - file per file con magic comment

### Decisione Architetturale: Mixed Operations

Il runtime deve supportare operazioni tra Number e BigInt:
- `42n + 10` → converti 10 a BigInt, poi opera
- `42n < 10` → confronto funziona nativamente in JS
- `42n / 3.14` → converti BigInt a Number per divisione con float

## Fasi di Migrazione (Riviste)

### ⏭️ Fase 1: Runtime Operator Helpers (PROSSIMO STEP - Priorità Critica)

**File da modificare:**
- `opal/runtime/op_helpers.rb` (righe 12-47)

**Modifiche necessarie:**
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

**Operatori da aggiornare:**
- [x] Identificato problema in `rb_lt` (less than)
- [ ] `rb_plus`, `rb_minus`, `rb_times`, `rb_divide`
- [ ] `rb_lt`, `rb_gt`, `rb_le`, `rb_ge`
- [ ] `eqeq`, `eqeqeq`, `neqeq`

**Casi speciali:**
- **Divisione con float:** `42n / 3.14` deve convertire BigInt → Number
- **Bitwise ops:** Già gestiti separatamente, dovrebbero funzionare
- **Modulo/Remainder:** Verificare comportamento con tipi misti

**Test:**
```bash
# Dopo le modifiche
mise exec -- bin/rake mspec_ruby_nodejs 2>&1 | head -100
```

**Successo quando:**
- MSpec suite inizia a eseguire test invece di crashare all'avvio
- Vediamo failure di test specifici (non runtime errors)

### Fase 2: Runtime Helpers Aggiuntivi (Priorità Alta)

**File:**
- `opal/runtime/helpers.rb` - coercizione

**Modifiche:**
- Aggiungere helper `$is_bigint()`
- Modificare `$coerce_to()` per gestire BigInt
- Helper di conversione: `$to_bigint()`, `$bigint_to_number()`

### Fase 3: Corelib Number (Priorità Alta)

**File:**
- `opal/corelib/number.rb` (969 righe)
- `opal/corelib/numeric.rb`

**Sfide:**
- Metodi con `%x{}` devono gestire tipi misti
- `__id__` usa bitwise che funziona diversamente con BigInt
- Coercizione tra Integer/Float

**Non necessario:**
- ❌ Aggiungere `# bigint_integers: true` ai file runtime (usano Number di proposito)
- ❌ Modificare tutti i literal in `%x{}` (troppo rischioso)

### Fase 4-7: Come da piano originale

(Restano invariate)

## Compatibilità Interop JavaScript

### ✅ Funziona Nativamente

JavaScript ES2020+ gestisce molte operazioni miste:
```javascript
42n < 10        // true - confronto funziona
42n + 10n       // 52n - somma BigInt
Number(42n)     // 42 - conversione esplicita
BigInt(42)      // 42n - conversione esplicita
```

### ⚠️ Non Funziona

```javascript
42n + 10        // TypeError: Cannot mix BigInt and other types
42n / 3.14      // TypeError: Cannot mix BigInt and other types
Math.sqrt(42n)  // TypeError: Cannot convert a BigInt value to a number
JSON.stringify({x: 42n})  // TypeError: Do not know how to serialize a BigInt
```

### 🔧 Soluzioni

1. **Operatori aritmetici misti** → Convertiamo nel runtime helper
2. **Math functions** → Convertiamo a Number quando necessario
3. **JSON** → Custom serializer (da implementare separatamente)

## Test di Regressione

**Baseline attuale:**
- `bin/rake rspec` → 473 examples, 0 failures ✅
- `bin/rake mspec_ruby_nodejs` → Crash con `l.$< is not a function` ❌

**Prossimi traguardi:**
1. MSpec suite esegue senza crash
2. Identificare quanti test falliscono (baseline)
3. Ridurre failure progressivamente

## Metriche di Successo

- [ ] **P0:** Runtime operator helpers gestiscono BigInt + Number
- [ ] **P0:** MSpec suite esegue senza crash all'avvio  
- [ ] **P1:** Suite RSpec verde con bigint_integers: true
- [ ] **P1:** MSpec suite > 80% test passanti
- [ ] **P2:** Tutti i test passano
- [ ] **P3:** Performance degradation < 20%
- [ ] **P3:** Documentazione aggiornata

## Prossimi Step Immediati

1. ✅ Aggiornare questo piano
2. ⏭️ Implementare mixed-type support in `op_helpers.rb`
3. ⏭️ Testare con mspec, raccogliere baseline failure
4. ⏭️ Prioritizzare fix in base a failure più comuni

## Note per Sviluppatori

- **Non modificare i literal in `%x{}`** - il runtime gestisce la conversione
- **Testare sempre con bigint disabled** prima di abilitarlo
- **Usare `typeof l === 'bigint'`** per check BigInt in JS
- **Ricordare:** BigInt non ha `-0`, `NaN`, `Infinity`
- **Divisione float:** Sempre converte a Number se uno degli operandi è float
