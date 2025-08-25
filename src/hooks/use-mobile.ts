import * as React from "react"

const MOBILE_BREAKPOINT = 768

export function useIsMobile() {
  const [isMobile, setIsMobile] = React.useState<boolean | undefined>(undefined)

  React.useEffect(() => {
    const mql = window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT - 1}px)`)
    const onChange = () => {
      setIsMobile(window.innerWidth < MOBILE_BREAKPOINT)
    }
    mql.addEventListener("change", onChange)
    setIsMobile(window.innerWidth < MOBILE_BREAKPOINT)
    return () => mql.removeEventListener("change", onChange)
  }, [])

  return !!isMobile
}

export function useMobile() {
  const [isMobile, setIsMobile] = React.useState<boolean | undefined>(undefined)
  const [isIPhone, setIsIPhone] = React.useState<boolean>(false)
  const [isIOS, setIsIOS] = React.useState<boolean>(false)

  React.useEffect(() => {
    const checkDevice = () => {
      const width = window.innerWidth
      const userAgent = navigator.userAgent
      
      // Check if mobile based on screen width
      setIsMobile(width < MOBILE_BREAKPOINT)
      
      // Check if iPhone specifically
      setIsIPhone(/iPhone/.test(userAgent))
      
      // Check if iOS (iPhone, iPad, iPod)
      setIsIOS(/iPad|iPhone|iPod/.test(userAgent))
    }

    checkDevice()
    const mql = window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT - 1}px)`)
    mql.addEventListener("change", checkDevice)
    
    return () => mql.removeEventListener("change", checkDevice)
  }, [])

  return {
    isMobile: !!isMobile,
    isIPhone,
    isIOS
  }
}
