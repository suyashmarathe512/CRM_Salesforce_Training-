import { LightningElement } from 'lwc';
import translateText from '@salesforce/apex/TranslationController.translateText';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Translator extends LightningElement {
    // Component state properties
    sourceText = '';
    sourceLang = 'auto'; // Default to auto-detect
    targetLang = 'es';   // Default to Spanish
    translatedText = '';
    isLoading = false;

    // Hardcoded language options for the dropdowns
    // LibreTranslate supports 'auto' for source language
    get languageOptions() {
        return [
            { label: 'Auto-Detect', value: 'auto' },
            { label: 'English', value: 'en' },
            { label: 'Spanish', value: 'es' },
            { label: 'French', value: 'fr' },
            { label: 'German', value: 'de' },
            { label: 'Japanese', value: 'ja' },
            { label: 'Chinese', value: 'zh' },
            { label: 'Russian', value: 'ru' },
            { label: 'Arabic', value: 'ar' },
            { label: 'Portuguese', value: 'pt' },
        ];
    }

    // --- INPUT HANDLERS ---

    handleTextChange(event) {
        this.sourceText = event.target.value;
    }

    handleSourceLangChange(event) {
        this.sourceLang = event.target.value;
    }

    handleTargetLangChange(event) {
        this.targetLang = event.target.value;
    }

    // --- ACTION HANDLER ---

    handleTranslate() {
        // Basic validation
        if (!this.sourceText || !this.targetLang) {
            this.showToast('Validation Error', 'Please enter text to translate and select a target language.', 'error');
            return;
        }

        // Set loading state
        this.isLoading = true;
        this.translatedText = ''; // Clear previous translation

        // Call the Apex method imperatively
        translateText({ 
            textToTranslate: this.sourceText, 
            sourceLang: this.sourceLang, 
            targetLang: this.targetLang 
        })
            .then(result => {
                // Success
                this.translatedText = result;
            })
            .catch(error => {
                // Failure
                this.showToast('Translation Error', this.getErrorMessage(error), 'error');
            })
            .finally(() => {
                // Always reset loading state
                this.isLoading = false;
            });
    }

    // --- UTILITY METHODS ---

    /**
     * Shows a toast notification.
     * @param {string} title - The title of the toast.
     * @param {string} message - The message body of the toast.
     * @param {string} variant - The toast variant (e.g., 'success', 'error', 'warning').
     */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    /**
     * Extracts a user-friendly error message from the Apex error object.
     * @param {object} error - The error object from the Apex call.
     * @returns {string} A user-friendly error message.
     */
    getErrorMessage(error) {
        if (error) {
            // Standard AuraHandledException
            if (error.body && error.body.message) {
                return error.body.message;
            }
            // Other JS exceptions
            if (error.message) {
                return error.message;
            }
        }
        return 'An unknown error occurred.';
    }
}
