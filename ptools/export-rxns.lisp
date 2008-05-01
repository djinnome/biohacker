(in-package :ecocyc)

(defun make-growth  (essential-compounds)
    `(growth ,@essential-compounds))

(setq *amino-acids*
  '(ALA ARG ASN ASP CYS GLN GLT GLY HIS ILE LEU LYS MET PHE PRO SER THR TRP TYR VAL))

(setq *dna-and-rna*
  '(DATP DTTP DGTP DCTP ATP UTP GTP CTP))

(setq *cytoplasmic-membrane*
  '(L-1-PHOSPHATIDYL-ETHANOLAMINE CARDIOLIPIN L-1-PHOSPHATIDYL-GLYCEROL))

(setq *outer-membrane* '(C6))
(setq *cell-wall*
  '(BISOHMYR-GLC ADP-L-GLYCERO-D-MANNO-HEPTOSE KDO UDP-GLUCOSE UDP-GALACTOSE DTDP-RHAMNOSE GDP-MANNOSE N-ACETYL-D-GLUCOSAMINE))

(setq *M63-growth-medium* '(GLC K PROTON |Pi| AMMONIUM SULFATE MG+2 WATER FE+2 MN+2 CU+2 CO+2 CA+2 ZN+2 CD+2 NI+2))

(defun make-experiment (nutrients ko &key (growth-p t))
  `(experiment ,(if growth-p 'growth 'no-growth)
	       (nutrients ,@nutrients)
	       (off ,@ko)))

(defun collect-pwys (pwy-list filter-p)
  (loop for pwy in pwy-list
       when (funcall filter-p pwy)
       collect (translate-pwy-to-tms pwy)))

(defun collect-pwy-catalyses (pwy-list filter-p)
  (loop for pwy in pwy-list
       when (funcall filter-p pwy)
       collect (translate-pwy-catalysis-to-tms pwy)))

(defun collect-pwy-enzymes (pwy-list filter-p)
  (loop for enzyme in (remove-duplicates
		       (loop for pwy in pwy-list
			    when (funcall filter-p pwy)
			    append (enzymes-of-pathway pwy)))
       collect (translate-enzyme-to-tms enzyme)))

(defun balanced-pwy-p (pwy)
  (and (coercible-to-frame-p pwy)
       (substrates-of-pwy-are-frames-p pwy)))

(defun collect-rxns (rxn-list filter-p)
  (loop for rxn in rxn-list
     when (funcall filter-p rxn)
     collect (translate-rxn-to-tms rxn)))

(defun collect-catalyses (rxn-list filter-p)
  (loop for rxn in rxn-list
       when (funcall filter-p rxn)
       collect (translate-catalysis-to-tms rxn)))

(defun collect-enzymes (rxn-list filter-p)
  (loop for enzyme in (remove-duplicates 
		       (loop for rxn in rxn-list
			  when (funcall filter-p rxn)
			  append (enzymes-of-reaction rxn)))
     collect (translate-enzyme-to-tms enzyme)))

(defun translate-pwy-to-tms (pwy)
  (multiple-value-bind 
	(all-reactants proper-reactants all-products proper-products)
      (substrates-of-pathway pwy)
    `(pwy ,(get-frame-name pwy)
	,proper-reactants
	,@all-products)))

(defun translate-pwy-catalysis-to-tms (pwy)
  `(pwy-catalyze ,(get-frame-name pwy)
		 ,@(enzymes-of-pathway pwy)))

(defun translate-catalysis-to-tms (rxn)
  `(catalyze ,(get-frame-name rxn)
	     ,@(enzymes-of-reaction rxn)))

(defun translate-enzyme-to-tms (enzyme)
  `(enzyme ,(get-frame-name enzyme)
	   ,@(genes-of-protein enzyme)))



(defun translate-rxn-to-tms (rxn)
  `(reaction ,(get-frame-name rxn) ,(get-slot-values rxn 'left) ,@(get-slot-values rxn 'right)))

(defun substrate-not-frame-p (rxn)
  (loop for substrate in (substrates-of-reaction rxn)
       if (not (coercible-to-frame-p substrate))
       return substrate))

(defun balanced-rxn-p (rxn)
  (and (coercible-to-frame-p rxn)
       (not (substrate-not-frame-p rxn))
       (atomic-balanced-p rxn 'C)
       (atomic-balanced-p rxn 'N)
       (atomic-balanced-p rxn 'S)
       (atomic-balanced-p rxn 'P)))

(defun substrates-of-pwy-are-frames-p (pwy)
  (not (loop for substrate in (compounds-of-pathway pwy)
	  if (not (coercible-to-frame-p substrate))
	  return substrate)))

(defun get-stoichiometry (rxn side participant)
  (let ((coeff (get-value-annot rxn side participant 'coefficient)))
    (if coeff
	coeff
	1)))

(defun get-atom-number (molecule the-atom)
  (or (loop for (atom num) in (get-slot-values molecule 'chemical-formula)
	 when (eq atom the-atom)
	 return num)
      0))

(defun get-num-atoms-on-side (rxn side the-atom)
  (loop for participant in (get-slot-values rxn side)
     sum (* (get-stoichiometry rxn side participant) 
	    (get-atom-number participant the-atom))))

(defun atomic-balanced-p (rxn the-atom)
  (let ((reactant-atoms 
	 (get-num-atoms-on-side rxn 'left the-atom))
	(product-atoms
	 (get-num-atoms-on-side rxn 'right the-atom)))
    (= 0 (- reactant-atoms product-atoms))))
    
	
	      