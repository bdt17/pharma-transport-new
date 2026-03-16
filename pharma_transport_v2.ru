# Replace the full_ui_page method with this FIXED version:
def self.full_ui_page
  <<~HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Pharma Transport - FDA 21 CFR Part 11</title>
  <style>/* SAME STYLES - KEEP WORKING */</style>
</head>
<body>
  <!-- SAME HTML STRUCTURE -->
  
  <script>
    // ✅ FIXED: Direct API calls (no CORS issues)
    async function generatePDF(type) {
      const btn = event.target;
      btn.disabled = true;
      btn.textContent = 'Generating PDF...';
      
      try {
        // 1. Get payment session
        const payResponse = await fetch('/pay', {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
          },
          body: 'email=biologics-pharma@thomasit.com'
        });
        
        const payData = await payResponse.json();
        if (!payData.session) throw new Error('Payment validation failed');
        
        // 2. Generate PDF with type parameter
        const pdfUrl = `/pdf?session=${payData.session}&type=${type}`;
        const pdfResponse = await fetch(pdfUrl);
        
        if (pdfResponse.ok) {
          const blob = await pdfResponse.blob();
          downloadBlob(blob, `LOT-${type.toUpperCase()}-${new Date().toISOString().slice(0,10)}-21cfr11.pdf`);
          showStatus(`✅ ${type.toUpperCase()} PDF Generated! $${PRICES[type]} (${blob.size} bytes)`, 'success');
        }
      } catch (error) {
        showStatus(`❌ ${error.message}`, 'error');
      } finally {
        btn.disabled = false;
        btn.textContent = `Generate ${type.charAt(0).toUpperCase() + type.slice(1)} PDF`;
      }
    }
    
    function downloadBlob(blob, filename) {
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }
  </script>
</body>
</html>
  HTML
end
