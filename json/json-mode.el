;;; json-mode.el --- Major mode for editing JSON files

;; Copyright (C) 2011-2013 Josh Johnston

;; Author: Josh Johnston
;; URL: https://github.com/joshwnj/json-mode
;; Version: 1.1.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; extend the builtin js-mode's syntax highlighting

;;; Code:

(require 'js)
(require 'rx)

(defconst json-mode-quoted-string-re
  (rx (group (char ?\")
(zero-or-more (or (seq ?\\ ?\\)
(seq ?\\ ?\")
(seq ?\\ (not (any ?\" ?\\)))
(not (any ?\" ?\\))))
(char ?\"))))
(defconst json-mode-quoted-key-re
(rx (group (char ?\")
(zero-or-more (or (seq ?\\ ?\\)
(seq ?\\ ?\")
(seq ?\\ (not (any ?\" ?\\)))
(not (any ?\" ?\\))))
(char ?\"))
(zero-or-more blank)
?\:))
(defconst json-mode-number-re (rx (group (one-or-more digit)
(optional ?\. (one-or-more digit)))))
(defconst json-mode-keyword-re (rx (group (or "true" "false" "null"))))

(defconst json-font-lock-keywords-1
(list
(list json-mode-quoted-key-re 1 font-lock-keyword-face)
(list json-mode-quoted-string-re 1 font-lock-string-face)
(list json-mode-keyword-re 1 font-lock-constant-face)
(list json-mode-number-re 1 font-lock-constant-face)
)
"Level one font lock.")

(defconst json-mode-lint
  "jsonlint --indent \"	\"")

(defconst json-mode-lint-sort
  "jsonlint --sort-keys --indent \"	\"")

;;;###autoload
(defun json-mode-beautify (beg end &optional preserve-key-order)
  "Beautify / pretty-print from BEG to END, and optionally PRESERVE-KEY-ORDER."
  (interactive "r\nP")
  (shell-command-on-region (if mark-active beg (point-min))
                           (if mark-active end (point-max))
                           (concat (if preserve-key-order json-mode-lint json-mode-lint-sort))
                           (current-buffer) t))

;;;###autoload
(defun json-mode-beautify-ordered (beg end)
  "Beautify / pretty-print from BEG to END preserving key order."
  (interactive "r")
  (json-mode-beautify beg end t))

;;;###autoload
(define-derived-mode json-mode javascript-mode "JSON"
  "Major mode for editing JSON files"
  (set (make-local-variable 'font-lock-defaults) '(json-font-lock-keywords-1 t))
  (run-hooks 'json-mode-hook))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.json$" . json-mode))

(define-key json-mode-map (kbd "C-c C-f") 'json-mode-beautify)

(provide 'json-mode)
;;; json-mode.el ends here
