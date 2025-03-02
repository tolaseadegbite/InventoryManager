import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inventoryChart", "categoryChart", "categoryTable", "inventoryActionsChart"]

  connect() {
    // Load ApexCharts only once when needed
    if (this.hasInventoryChartTarget || this.hasCategoryChartTarget || this.hasInventoryActionsChartTarget) {
      this.loadApexCharts()
    }
  }

  loadApexCharts() {
    // Check if ApexCharts is already loaded
    if (window.ApexCharts) {
      this.initializeCharts()
      return
    }

    // Load ApexCharts dynamically
    const script = document.createElement('script')
    script.src = 'https://cdn.jsdelivr.net/npm/apexcharts'
    script.onload = () => this.initializeCharts()
    script.onerror = () => this.showChartError()
    document.head.appendChild(script)
  }

  searchCategories(event) {
    const searchTerm = event.target.value.toLowerCase()
    
    if (this.hasCategoryTableTarget) {
      const rows = this.categoryTableTarget.querySelectorAll('[data-category-name]')
      
      rows.forEach(row => {
        const categoryName = row.dataset.categoryName
        if (categoryName.includes(searchTerm)) {
          row.classList.remove('hidden')
        } else {
          row.classList.add('hidden')
        }
      })
    }
  }

  showChartError() {
    const errorMessage = '<div class="flex items-center justify-center h-full text-gray-500">Unable to load charts</div>'
    
    if (this.hasInventoryChartTarget) {
      this.inventoryChartTarget.innerHTML = errorMessage
    }
    
    if (this.hasCategoryChartTarget) {
      this.categoryChartTarget.innerHTML = errorMessage
    }
    
    if (this.hasInventoryActionsChartTarget) {
      this.inventoryActionsChartTarget.innerHTML = errorMessage
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
      
      if (this.hasInventoryActionsChartTarget) {
        this.initializeInventoryActionsChart()
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
              colors: '#6B7280',
              fontSize: '12px'
            }
          }
        },
        yaxis: {
          labels: {
            style: {
              colors: '#6B7280'
            }
          }
        },
        colors: ['#3B82F6'],
        stroke: {
          curve: 'smooth',
          width: 2
        },
        fill: {
          type: 'gradient',
          gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.7,
            opacityTo: 0.2,
            stops: [0, 90, 100]
          }
        },
        dataLabels: {
          enabled: false
        },
        grid: {
          borderColor: '#E5E7EB',
          strokeDashArray: 4,
          xaxis: {
            lines: {
              show: true
            }
          }
        },
        tooltip: {
          theme: document.documentElement.classList.contains('dark') ? 'dark' : 'light'
        }
      }
      
      new ApexCharts(this.inventoryChartTarget, options).render()
    } catch (error) {
      console.error('Error initializing inventory chart:', error)
      this.showChartError()
    }
  }

  initializeCategoryChart() {
    try {
      const categoryData = JSON.parse(this.categoryChartTarget.dataset.categories || '[]')
      
      if (!categoryData.length) {
        this.categoryChartTarget.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">No data available</div>'
        return
      }
      
      const options = {
        chart: {
          type: 'pie',
          height: 320,
          toolbar: { show: false },
          fontFamily: 'Inter, system-ui, sans-serif',
          animations: {
            enabled: false // Disable animations for better performance
          }
        },
        series: categoryData.map(item => item.count),
        labels: categoryData.map(item => item.name),
        colors: [
          '#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', 
          '#EC4899', '#14B8A6', '#F97316', '#6366F1', '#06B6D4'
        ],
        legend: {
          position: 'bottom',
          fontSize: '14px',
          markers: {
            width: 12,
            height: 12,
            radius: 12
          },
          itemMargin: {
            horizontal: 10,
            vertical: 5
          }
        },
        dataLabels: {
          enabled: true,
          formatter: function (val, opts) {
            return opts.w.config.series[opts.seriesIndex]
          },
          style: {
            fontSize: '14px',
            fontFamily: 'Inter, system-ui, sans-serif',
            fontWeight: 'bold'
          },
          dropShadow: {
            enabled: false
          }
        },
        tooltip: {
          y: {
            formatter: function(value) {
              return value + ' items'
            }
          }
        },
        responsive: [{
          breakpoint: 480,
          options: {
            chart: {
              height: 300
            },
            legend: {
              position: 'bottom'
            }
          }
        }]
      }
      
      new ApexCharts(this.categoryChartTarget, options).render()
    } catch (error) {
      console.error('Error initializing category chart:', error)
      this.showChartError()
    }
  }
  
  initializeInventoryActionsChart() {
    try {
      const actionsData = JSON.parse(this.inventoryActionsChartTarget.dataset.actions || '[]')
      
      if (!actionsData.length) {
        this.inventoryActionsChartTarget.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">No data available</div>'
        return
      }
      
      const options = {
        chart: {
          type: 'bar',
          height: 320,
          stacked: true,
          toolbar: { show: false },
          fontFamily: 'Inter, system-ui, sans-serif',
          animations: {
            enabled: false // Disable animations for better performance
          }
        },
        series: [
          {
            name: 'Add Quantity',
            data: actionsData.map(item => item.add)
          },
          {
            name: 'Remove Quantity',
            data: actionsData.map(item => item.remove)
          }
        ],
        xaxis: {
          categories: actionsData.map(item => item.date),
          labels: {
            style: {
              colors: '#6B7280',
              fontSize: '12px'
            }
          }
        },
        yaxis: {
          title: {
            text: 'Number of Actions'
          },
          labels: {
            style: {
              colors: '#6B7280'
            }
          }
        },
        legend: {
          position: 'top',
          horizontalAlign: 'left',
          offsetY: 0,
          fontSize: '14px',
          markers: {
            width: 12,
            height: 12,
            radius: 12
          }
        },
        fill: {
          opacity: 1
        },
        colors: ['#10B981', '#EF4444'],
        dataLabels: {
          enabled: false
        },
        grid: {
          borderColor: '#E5E7EB',
          strokeDashArray: 4,
          xaxis: {
            lines: {
              show: false
            }
          }
        },
        tooltip: {
          y: {
            formatter: function (val) {
              return val + " actions"
            }
          }
        }
      }
      
      new ApexCharts(this.inventoryActionsChartTarget, options).render()
    } catch (error) {
      console.error('Error initializing inventory actions chart:', error)
      this.showChartError()
    }
  }
}