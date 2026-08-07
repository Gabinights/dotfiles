(setq gc-cons-threshold (* 50 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1024 1024))))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq-default fill-column 80)

(electric-pair-mode 1)

;; Define o estilo como relativo
(setq display-line-numbers-type t)

;; Ativa globalmente
(global-display-line-numbers-mode 1)

;; Desativa em modos onde não fazem sentido (Org, PDFs, Terminais)
(dolist (mode '(org-mode-hook
                pdf-view-mode-hook
                term-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode -1))))

(require 'package)

;; Adiciona o repositório da comunidade (MELPA)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Garante que a lista de pacotes está atualizada no primeiro arranque
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(setq package-install-upgrade-built-in t)
(require 'use-package)
(setq use-package-always-ensure t)

(use-package vertico
  :init (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ;; Os nossos atalhos de pesquisa personalizados
         ("C-c s s" . consult-line)
         ("C-c s r" . consult-ripgrep)))

(use-package which-key
  :ensure nil ; Built-in no Emacs 30
  :init (which-key-mode 1)
  :config
  ;; Dá nomes bonitos aos menus do C-c
  (which-key-add-key-based-replacements
    "C-c s" "Pesquisa"
    "C-c c" "Código/Estrutura"
    "C-c a" "Ações/Contexto"
    "C-c n" "Notas/Org"
    "C-c n d" "Dailies"
    "C-c g" "Git"
    "C-c l" "Leitura/RSS"
    "C-c p" "Projetos"))

(use-package embark
  :bind
  (("C-." . embark-act)         
   ("M-." . embark-dwim)        
   ("C-h B" . embark-bindings)
   ;; Atalhos organizados no menu "Ações"
   ("C-c a a" . embark-act)
   ("C-c a d" . embark-dwim)
   ("C-c a e" . embark-export)
   ("C-c a b" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (setq embark-indicators
        '(embark-minimal-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator)))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package doom-themes
  :config
  (load-theme 'doom-dracula t))

(use-package org-modern
  :hook (org-mode . org-modern-mode))

(use-package nerd-icons)

(use-package nerd-icons-completion
  :after (marginalia vertico)
  :init
  (nerd-icons-completion-mode)
  :hook
  (marginalia-mode . nerd-icons-completion-marginalia-setup))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 30)
  (doom-modeline-bar-width 4)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-workspace-name t)
  (doom-modeline-time t))

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(use-package org
  :bind (("C-c n a" . org-agenda))
  :hook (org-mode . visual-line-mode)
  :custom
  (org-directory "~/org/")
  (org-agenda-files '("~/org/agenda/" "~/org/roam/daily/"))
  (org-todo-keywords
   '((sequence "TODO(t)" "DOING(i)" "WAIT(w)" "|" "DONE(d)" "CANCEL(c)")))
  (org-todo-keyword-faces
   '(("DOING" . (:foreground "#ffb86c" :weight bold))
     ("WAIT"  . (:foreground "#8be9fd" :weight bold))
     ("CANCEL". (:foreground "#6272a4" :weight bold))))
  (org-hide-emphasis-markers t)
  (org-startup-indented t)
  (org-src-fontify-natively t)
  (org-src-preserve-indentation nil)
  (org-edit-src-content-indentation 0)
  (org-src-tab-acts-natively t)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (python . t)
     (C . t)))
  (require 'org-tempo)
  (setq org-confirm-babel-evaluate
        (lambda (lang body)
          (not (member lang '("C" "shell" "emacs-lisp" "python"))))))

(use-package org-download
  :after org
  :defer t
  :bind ("C-c n v" . org-download-clipboard)
  :config
  (org-download-enable)
  (setq-default org-download-image-dir "./images")
  (setq org-download-screenshot-method "wl-paste -t image/png > %s"))

(use-package flycheck
  :init
  (global-flycheck-mode))

(use-package treesit
  :ensure nil
  :bind (("C-c c m" . treesit-explore-mode)
         ("C-c c f" . treesit-beginning-of-defun)
         ("C-c c e" . treesit-end-of-defun)))

;; 1. Dizer ao Emacs a localização exata das gramáticas testadas
(setq treesit-language-source-alist
  '((bash       "https://github.com/tree-sitter/tree-sitter-bash")
    (python     "https://github.com/tree-sitter/tree-sitter-python")
    (json       "https://github.com/tree-sitter/tree-sitter-json")
    (yaml       "https://github.com/ikatyang/tree-sitter-yaml")
    (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")))

;; 2. Instalar automaticamente as gramáticas
(dolist (lang '(bash python json yaml dockerfile))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

;; 3. Configurar o treesit-auto
(use-package treesit-auto
  :custom
  (treesit-auto-install nil)
  :config
  (setq treesit-auto-langs '(python bash json yaml dockerfile))
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package org-roam
  :ensure t
  :demand t
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n t" . org-roam-tag-add)
         ("C-c n d d" . org-roam-dailies-goto-today)
         ("C-c n d y" . org-roam-dailies-goto-yesterday)
         ("C-c n d m" . org-roam-dailies-goto-tomorrow))
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  (org-roam-dailies-directory "daily/")
  (org-roam-dailies-capture-templates
    '(("d" "default" entry
      "* Sessão de Trabalho: %?w"
      :target (file+head "%<%Y-%m-%d>.org" 
                         "#+title: %<%Y-%m-%d>\n#+filetags: :diario:sessao:\n\n* [/] Tarefas da Sessão\n** TODO Rever pendentes da sessão anterior\n** TODO %?\n\n* Notas de Engenharia & Logs\n"))))
  :config
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (require 'org-id)
  (setq org-id-track-globally t)
  (org-roam-db-autosync-mode))

(use-package magit
  :bind ("C-c g s" . magit-status)
  :commands magit-status)

(use-package org-roam-ui
  :after org-roam
  :bind ("C-c n u" . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(use-package pdf-tools
  :defer t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :bind ("C-c s p" . pdf-occur)
  :config
  (pdf-tools-install :no-query)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t))

(use-package org-noter
  :defer t
  :config
  (setq org-noter-always-create-frame nil)
  (setq org-noter-kill-frame-at-session-end nil)
  (setq org-noter-doc-split-fraction '(0.5 . 0.5))
  (setq org-noter-notes-search-path '("~/org/roam")))

(use-package citar
  :bind ("C-c n x" . citar-insert-citation)
  :custom
  (citar-bibliography '("~/org/roam/referencias.bib"))
  (citar-library-paths '("~/org/refs/"))
  :hook
  (org-mode . citar-capf-setup))

(use-package citar-org-roam
  :after (citar org-roam)
  :config
  (citar-org-roam-mode))

(use-package tex
  :ensure auctex
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view)))
  (TeX-source-correlate-start-server t)
  :hook
  (LaTeX-mode . TeX-source-correlate-mode)
  (TeX-after-compilation-finished . TeX-revert-document-buffer))

(use-package projectile
  :init
  (projectile-mode +1)
  :custom
  (projectile-project-search-path '("~/dev/"))
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-dwim-target t))

(use-package gptel
  :ensure t
  :bind (("C-c q" . gptel-menu)   ; Abre o menu interativo (O que você quer)
         ("C-c RET" . gptel-send)) ; Envia instantaneamente (Para chat rápido)
  :config
  ;; O llama-server imita a API da OpenAI perfeitamente
  (setq gptel-backend 
        (gptel-make-openai "llama.cpp" 
          :protocol "http"
          :host "localhost:8080"
          :stream t
          :key "no-key"
          :models '("Llama-3.2-3B")))
  
  (setq gptel-model 'Llama-3.2-3B)
  
  (setq gptel-directives 
        '((default . "You are a senior embedded C engineer. Keep your answers technical, accurate, and concise. Do not use Markdown formatting unless requested."))))

(use-package khoj
  :ensure t
  :bind ("C-c n s" . khoj) ; Atalho: "Notes Search"
  :config
  ;; Aponta o Emacs para o servidor no seu RPi5
  (setq khoj-server-url "http://192.168.1.201:5000")
  
  ;; Opcional: Define a pasta padrão caso use a interface local do pacote
  (setq khoj-notes-directory "~/org/roam"))

(use-package elfeed
  :ensure t
  :bind (("C-c l e" . elfeed)
         ("C-c l u" . elfeed-update)
         :map elfeed-show-mode-map
         ("b" . my/elfeed-abrir-no-eww))
  :preface
  (defun my/elfeed-abrir-no-eww ()
    "Abre o artigo atual no EWW (browser interno) em vez do browser externo."
    (interactive)
    (let ((link (elfeed-entry-link elfeed-show-entry)))
      (when link
        (message "A descarregar o artigo completo...")
        (eww link))))
  :config
  ;; Atualiza o Elfeed a cada 30 minutos em background
  (run-at-time nil (* 30 60) #'elfeed-update))

(use-package elfeed-protocol
  :ensure t
  :after elfeed
  :config
  (setq elfeed-feeds
        '(("fever+https://gabi@vm-magasirala-rss.duckdns.org"
           :api-url "https://vm-magasirala-rss.duckdns.org/api/fever.php"
           :use-authinfo t
           :autotags ("freshrss"))))
  (elfeed-protocol-enable))
