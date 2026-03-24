document.addEventListener("DOMContentLoaded", function() {
  // Add copy buttons to all code blocks
  const codeBlocks = document.querySelectorAll('pre');
  
  codeBlocks.forEach(function(codeBlock) {
    // Create wrapper div for positioning
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    
    // Wrap the code block
    codeBlock.parentNode.insertBefore(wrapper, codeBlock);
    wrapper.appendChild(codeBlock);
    
    // Create copy button
    const copyButton = document.createElement('button');
    copyButton.className = 'copy-code-button';
    copyButton.innerHTML = '<span class="material-icons">content_copy</span>';
    copyButton.title = 'Copy code';
    
    // Style the button
    copyButton.style.position = 'absolute';
    copyButton.style.top = '8px';
    copyButton.style.right = '8px';
    copyButton.style.padding = '6px 8px';
    copyButton.style.background = '#fff';
    copyButton.style.border = '1px solid #ddd';
    copyButton.style.borderRadius = '4px';
    copyButton.style.cursor = 'pointer';
    copyButton.style.opacity = '0.7';
    copyButton.style.transition = 'opacity 0.2s, background 0.2s';
    copyButton.style.display = 'flex';
    copyButton.style.alignItems = 'center';
    copyButton.style.fontSize = '14px';
    copyButton.style.zIndex = '10';
    
    // Add hover effect
    copyButton.addEventListener('mouseenter', function() {
      copyButton.style.opacity = '1';
      copyButton.style.background = '#f5f5f5';
    });
    
    copyButton.addEventListener('mouseleave', function() {
      copyButton.style.opacity = '0.7';
      copyButton.style.background = '#fff';
    });
    
    // Add click handler
    copyButton.addEventListener('click', function() {
      const code = codeBlock.querySelector('code') || codeBlock;
      const text = code.textContent;
      
      // Copy to clipboard
      navigator.clipboard.writeText(text).then(function() {
        // Show success feedback
        const originalHTML = copyButton.innerHTML;
        copyButton.innerHTML = '<span class="material-icons">check</span>';
        copyButton.style.background = '#4CAF50';
        copyButton.style.color = '#fff';
        copyButton.style.borderColor = '#4CAF50';
        
        // Reset after 2 seconds
        setTimeout(function() {
          copyButton.innerHTML = originalHTML;
          copyButton.style.background = '#fff';
          copyButton.style.color = 'inherit';
          copyButton.style.borderColor = '#ddd';
        }, 2000);
      }).catch(function(err) {
        console.error('Failed to copy:', err);
        // Fallback for older browsers
        const textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();
        try {
          document.execCommand('copy');
          const originalHTML = copyButton.innerHTML;
          copyButton.innerHTML = '<span class="material-icons">check</span>';
          copyButton.style.background = '#4CAF50';
          copyButton.style.color = '#fff';
          setTimeout(function() {
            copyButton.innerHTML = originalHTML;
            copyButton.style.background = '#fff';
            copyButton.style.color = 'inherit';
          }, 2000);
        } catch (err) {
          console.error('Fallback copy failed:', err);
        }
        document.body.removeChild(textarea);
      });
    });
    
    wrapper.appendChild(copyButton);
  });
});
