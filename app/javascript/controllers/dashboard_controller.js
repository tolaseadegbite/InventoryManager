import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inventoryChart", "categoryChart", "categoryTable"]
  
  connect() {
    // Load ApexCharts only once when needed
    if (this.hasInventoryChartTarget || this.hasCategoryChartTarget) {
      this.loadApexCharts()
    }
  }
  
  loadApexCharts() {
    // Check if ApexCharts is already loaded
    if (window.ApexCharts) {
      this.initializeCharts()
      return
    }
    
    // Create script element
    const script = document.createElement('script')
    script.src = "https://cdn.jsdelivr.net/npm/apexcharts@3.41.0/dist/apexcharts.min.js"
    script.async = true
    
    // Initialize charts once script is loaded
    script.onload = () => {
      this.initializeCharts()
    }
    
    // Handle loading errors
    script.onerror = () => {
      console.error("Failed to load ApexCharts")
      this.showChartError()
    }
    
    // Add script to document
    document.head.appendChild(script)
  }
  
  showChartError() {
    const errorMessage = '<div class="flex items-center justify-center h-full text-gray-500">Unable to load charts</div>'
    
    if (this.hasInventoryChartTarget) {
      this.inventoryChartTarget.innerHTML = errorMessage
    }
    
    if (this.hasCategoryChartTarget) {
      this.categoryChartTarget.innerHTML = errorMessage
    }
  }
  
  initializeCharts() {
    // Use requestAnimationFrame to avoid forced reflow
    requestAnimationFrame(() => {
      if (this.hasInventoryChartTarget) {
        this.initializeInventoryChart()
      }
      
      if (this.hasCategoryChartTarget) {
        this.initializeCategoryChart()
      }
    })
  }
  
  initializeInventoryChart() {
    try {
      const trendsData = JSON.parse(this.inventoryChartTarget.dataset.trends || '[]')
      
      if (!trendsData.length) {
        this.inventoryChartTarget.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">No data available</div>'
        return
      }
      
      const options = {
        chart: {
          type: 'area',
          height: 320,
          toolbar: { show: false },
          fontFamily: 'Inter, system-ui, sans-serif',
          animations: {
            enabled: false // Disable animations for better performance
          }
        },
        series: [{
          name: 'Total Items',
          data: trendsData.map(item => item.count)
        }],
        xaxis: {
          categories: trendsData.map(item => item.month),
          labels: {
            style: {
              cssClass: 'text-xs font-normal'
            }
          }
        },
        colors: ['#3b82f6'],
        stroke: {
          curve: 'smooth',
          width: 2
        },
        fill: {
          type: 'gradient',
          gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.7,
            opacityTo: 0.3,
            stops: [0, 90, 100]
          }
        },
        dataLabels: {
          enabled: false
        },
        tooltip: {
          theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light'
        }
      }
      
      const chart = new window.ApexCharts(this.inventoryChartTarget, options)
      chart.render()
      this.inventoryChart = chart
    } catch (error) {
      console.error("Error initializing inventory chart:", error)
      this.inventoryChartTarget.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">Error loading chart</div>'
    }
  }
  
  initializeCategoryChart() {
    try {
      const categoriesData = JSON.parse(this.categoryChartTarget.dataset.categories || '[]')
      
      if (!categoriesData.length) {
        this.categoryChartTarget.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">No data available</div>'
        return
      }
      
      const options = {
        chart: {
          type: 'donut',
          height: 320,
          fontFamily: 'Inter, system-ui, sans-serif',
          animations: {
            enabled: false // Disable animations for better performance
          }
        },
        series: categoriesData.map(item => item.count),
        labels: categoriesData.map(item => item.name),
        colors: ['#3b82f6', '#10b981', '#f59e0b', '#6366f1', '#ec4899', '#8b5cf6', '#14b8a6'],
        legend: {
          position: 'bottom',
          horizontalAlign: 'center',
          fontSize: '14px'
        },
        tooltip: {
          theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light'
        },
        plotOptions: {
          pie: {
            donut: {
              size: '60%'
            }
          }
        },
        responsive: [{
          breakpoint: 480,
          options: {
            chart: {
              height: 260
            },
            legend: {
              position: 'bottom'
            }
          }
        }]
      }
      
      const chart = new window.ApexCharts(this.categoryChartTarget, options)
      chart.render()
      this.categoryChart = chart
    } catch (error) {
      console.error("Error initializing category chart:", error)
      this.categoryChartTarget.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">Error loading chart</div>'
    }
  }
  
  searchCategories(event) {
    const searchTerm = event.target.value.toLowerCase().trim();
    
    if (!this.hasCategoryTableTarget) return;
    
    // Get all elements with data-category-name attribute
    const allCategoryElements = document.querySelectorAll('[data-category-name]');
    
    // Filter elements based on search term
    allCategoryElements.forEach(element => {
      const categoryName = element.dataset.categoryName;
      if (!categoryName) return;
      
      if (categoryName.includes(searchTerm)) {
        element.classList.remove('hidden');
      } else {
        element.classList.add('hidden');
      }
    });
  }
}