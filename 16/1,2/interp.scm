(module interp (lib "eopl.ss" "eopl")
  
  (require "drscheme-init.scm")

  (require "lang.scm")
  (require "data-structures.scm")
  (require "environments.scm")

  (provide value-of-program value-of)

;;;;;;;;;;;;;;;; the interpreter ;;;;;;;;;;;;;;;;

  ;; value-of-program : Program -> Expval
  (define value-of-program 
    (lambda (pgm)
      (cases program pgm
        (a-program (body)
          (value-of body (init-env))))))


  ;; value-of : Exp * Env -> ExpVal
  (define value-of
    (lambda (exp env)
      (cases expression exp

        (const-exp (num)(num-val num))

        (var-exp (var) (apply-env env var))

        (diff-exp (exp1 exp2)
          (let ((val1
                 (expval->num
                  (value-of exp1 env)))
                (val2
                 (expval->num
                  (value-of exp2 env))))
            (num-val
             (- val1 val2))))
        
        (zero?-exp (exp1)
          (let ((val1 (expval->num (value-of exp1 env))))
            (if (zero? val1)
                (bool-val #t)
                (bool-val #f))))
        
        (if-exp (exp0 exp1 exp2)
          (if (expval->bool (value-of exp0 env))
              (value-of exp1 env)
              (value-of exp2 env)))
        
        (let-exp (var exp1 body)
          (let ((val (value-of exp1 env)))
            (value-of body
                      (extend-env var val env))))
        
        (proc-exp (bound-variables types body)
          (proc-val
           (procedure bound-variables body env)))

        (call-exp (rator rands)
          (let ((proc (expval->proc (value-of rator env)))
                (args (map (lambda (rand)
                             (value-of rand env))
                           rands)))
            (apply-procedure proc args)))
        
        (letrec-exp (ty1 p-name b-var ty2 p-body letrec-body)
           (value-of letrec-body 
                     (extend-env-rec p-name b-var p-body env)))
        
        (assign-exp (var-type var exp)  ;; set int x = -(5,4);
           (eopl:error "just checking in this language, not running"))
        
	    )))

  ;; apply-procedure : Proc * ExpVal -> ExpVal
  (define apply-procedure
    (lambda (proc1 arg)
      (cases proc proc1
        (procedure (var body saved-env)
          (value-of body (extend-env var arg saved-env))))))
  
  )
  


  
