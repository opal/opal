# BigInt Migration Plan

Piano per migrare gradualmente la corelib di Opal da Number (JS) a BigInt (JS) per rappresentare Integer (Ruby).

## Stato Attuale

- ✅ Compilatore: opzione `bigint_integers` implementata
- ✅ I literal Integer possono essere compilati come `42n` invece di `42`
- ⏳ Runtime: `opal/corelib/number.rb` usa ancora Number internamente

## Strategia

Abilitare `bigint_integers: true` file per file nella corelib, iniziando dai file che:
1. Non dipendono da operazioni aritmetiche complesse
2. Sono più facili da testare in isolamento
3. Hanno meno interazioni con JavaScript nativo

## Fasi di Migrazione

### Fase 1: Runtime Helpers (Priorità Alta)

File che dovranno supportare BigInt nelle loro implementazioni JS:

- [ ] `opal/runtime/helpers.js` - helpers di conversione e coercizione
- [ ] `opal/runtime/runtime.js` - funzioni core che manipolano numeri

**Azioni necessarie:**
- Aggiungere helper `$is_bigint()`, `$to_bigint()`, `$bigint_or_number()`
- Modificare `$coerce_to()` per gestire BigInt
- Aggiornare operatori inline (se `inline_operators: true`)

### Fase 2: File Base (Priorità Alta)

File da convertire per primi, con magic comment `# bigint_integers: true`:

1. [ ] `opal/corelib/numeric.rb` - classe base, pochi literal
2. [ ] `opal/corelib/comparable.rb` - principalmente confronti
3. [ ] `opal/corelib/constants.rb` - solo definizioni di costanti

**Test da verificare:**
```bash
bin/rake mspec_nodejs PATTERN="spec/ruby/core/numeric/*_spec.rb"
bin/rake mspec_nodejs PATTERN="spec/ruby/core/comparable/*_spec.rb"
```

### Fase 3: Number/Integer (Priorità Alta)

Il file più critico:

4. [ ] `opal/corelib/number.rb` - 969 righe, contiene sia Integer che Float

**Sfide principali:**
- `__id__` usa bit manipulation (riga 43-44)
- Operazioni inline JS embedded (`%x{}`)
- Distinzione Integer vs Float nello stesso file
- Coercizione con altri tipi

**Approccio:**
- Separare logica Integer vs Float dove possibile
- Wrapper per operazioni bitwise: `(BigInt(self) | 0n) === BigInt(self)`
- Test intensivo su `spec/ruby/core/integer/` e `spec/ruby/core/float/`

### Fase 4: File Dipendenti da Integer (Priorità Media)

File che usano Integer ma non implementano logica numerica complessa:

5. [ ] `opal/corelib/range.rb` - usa Integer per ranges numerici
6. [ ] `opal/corelib/array.rb` - index sono Integer
7. [ ] `opal/corelib/string.rb` - operazioni su index/length
8. [ ] `opal/corelib/hash.rb` - hash codes potrebbero essere BigInt

**Test:**
```bash
bin/rake mspec_nodejs PATTERN="spec/ruby/core/{range,array,string,hash}/*_spec.rb"
```

### Fase 5: Math e Complex Numbers (Priorità Media)

File che fanno matematica:

9. [ ] `opal/corelib/math/math.rb`
10. [ ] `opal/corelib/rational/rational.rb`
11. [ ] `opal/corelib/complex/complex.rb`

**Note:**
- Rational può beneficiare molto da BigInt (precisione arbitraria)
- Math.floor/ceil dovranno gestire BigInt
- Complex probabilmente rimarrà su Number per le parti immaginarie

### Fase 6: Resto della Corelib (Priorità Bassa)

File che usano Integer in modo marginale:

- [ ] `opal/corelib/enumerable.rb`
- [ ] `opal/corelib/enumerator.rb`
- [ ] `opal/corelib/time.rb` - timestamp potrebbero essere BigInt
- [ ] `opal/corelib/random/random.rb`
- [ ] Altri file...

### Fase 7: Stdlib (Priorità Bassa)

Dopo che tutta la corelib funziona:

- [ ] `stdlib/**/*.rb` - caso per caso

## Test di Regressione

Per ogni file convertito:

1. Run test specifici del modulo
2. Run test suite completa: `bin/rake mspec_nodejs`
3. Run minitest: `bin/rake minitest_nodejs`
4. Controllare che non ci siano regressioni nei filtri: `spec/filters/bugs/`

## Compatibilità Interop JavaScript

### Problemi Noti

1. **JSON.stringify** non supporta BigInt nativamente
   - Soluzione: custom serializer per Integer
   
2. **Operatori JS** (`+`, `-`, `*`, `/`) non funzionano tra Number e BigInt
   - Soluzione: coercizione esplicita in tutti gli helper

3. **Math.** functions non accettano BigInt
   - Soluzione: convertire a Number quando necessario, documentare loss of precision

4. **Bitwise ops** funzionano diversamente
   - BigInt: precisione arbitraria
   - Number: 32-bit signed
   - Soluzione: usare sempre BigInt per bitwise su Integer

## Metriche di Successo

- [ ] Tutti i test passano con `bigint_integers: true` globalmente
- [ ] Nessun degrado di performance > 20% su benchmark critici
- [ ] Documentazione aggiornata
- [ ] Esempi funzionanti con BigInt

## Timeline Stimata

- Fase 1-2: 1-2 settimane (fondamenta)
- Fase 3: 2-3 settimane (parte più complessa)
- Fase 4-5: 2-3 settimane
- Fase 6-7: 3-4 settimane
- **Totale**: 2-3 mesi di lavoro part-time

## Note per Sviluppatori

- Testare sempre sia con `bigint_integers: false` che `true`
- Usare `# bigint_integers: true` solo quando il file è pronto
- Documentare ogni workaround JavaScript
- Aggiungere commenti quando la semantica BigInt diverge da Number
- Considerare che BigInt non ha `-0`, `NaN`, `Infinity` come Number
