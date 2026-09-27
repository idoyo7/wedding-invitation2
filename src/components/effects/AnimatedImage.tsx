'use client';

import React, { useState } from 'react';
import { motion, type Variants } from 'framer-motion';
import Image from 'next/image';
import styled from 'styled-components';
import { weddingConfig } from '../../config/wedding-config';

interface AnimatedImageProps {
  src: string;
  alt: string;
  fill?: boolean;
  sizes?: string;
  quality?: number;
  priority?: boolean;
  style?: React.CSSProperties;
  draggable?: boolean;
  onContextMenu?: (e: React.MouseEvent) => void;
  onClick?: () => void;
  className?: string;
}

const AnimatedImage: React.FC<AnimatedImageProps> = ({ 
  src, 
  alt, 
  fill = false,
  sizes,
  quality = 75,
  priority = false,
  style = {},
  draggable = false,
  onContextMenu,
  onClick,
  className
}) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const { effects } = weddingConfig;

  const imageVariants: Variants = {
    hidden: { 
      opacity: 0, 
      scale: 0.8 
    },
    visible: { 
      opacity: 1, 
      scale: 1,
      transition: {
        duration: 0.6,
        ease: [0.25, 0.46, 0.45, 0.94]
      }
    },
    hover: effects.enabled && effects.imageHover ? {
      scale: 1.05,
      rotate: Math.random() > 0.5 ? 1 : -1, // 랜덤하게 좌우 기울기
      transition: {
        duration: 0.3,
        ease: "easeOut"
      }
    } : {},
    tap: effects.enabled && effects.imageHover ? {
      scale: 0.98,
      transition: {
        duration: 0.1
      }
    } : {}
  };

  return (
    <ImageContainer 
      className={className}
      onClick={onClick}
      $clickable={!!onClick}
    >
      <LoadingOverlay 
        $visible={!isLoaded}
        initial={{ opacity: 1 }}
        animate={{ opacity: isLoaded ? 0 : 1 }}
        transition={{ duration: 0.3 }}
      >
        <LoadingSpinner />
      </LoadingOverlay>
      
      <StyledMotionDiv
        variants={imageVariants}
        initial="hidden"
        animate={isLoaded ? "visible" : "hidden"}
        whileHover="hover"
        whileTap="tap"
        $effectsEnabled={effects.enabled && effects.galleryAnimation}
      >
        <Image
          src={src}
          alt={alt}
          fill={fill}
          sizes={sizes}
          quality={quality}
          priority={priority}
          style={style}
          draggable={draggable}
          onContextMenu={onContextMenu}
          onLoad={() => setIsLoaded(true)}
          onError={() => setIsLoaded(true)} // 에러 시에도 로딩 완료로 처리
        />
      </StyledMotionDiv>
      
      {effects.enabled && effects.imageHover && onClick && (
        <HoverOverlay
          initial={{ opacity: 0 }}
          whileHover={{ opacity: 1 }}
          transition={{ duration: 0.2 }}
        >
          <HoverText>클릭하여 확대</HoverText>
        </HoverOverlay>
      )}
    </ImageContainer>
  );
};

const ImageContainer = styled.div<{ $clickable: boolean }>`
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  border-radius: 8px;
  cursor: ${props => props.$clickable ? 'pointer' : 'default'};
`;

const LoadingOverlay = styled(motion.div)<{ $visible: boolean }>`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(245, 245, 245, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2;
  backdrop-filter: blur(2px);
`;

const LoadingSpinner = styled.div`
  width: 32px;
  height: 32px;
  border: 3px solid rgba(0, 0, 0, 0.1);
  border-top: 3px solid var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
`;

const StyledMotionDiv = styled(motion.div)<{ $effectsEnabled: boolean }>`
  width: 100%;
  height: 100%;
  will-change: ${props => props.$effectsEnabled ? 'transform' : 'auto'};
`;

const HoverOverlay = styled(motion.div)`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
`;

const HoverText = styled.div`
  color: white;
  font-size: 14px;
  font-weight: 500;
  text-align: center;
  padding: 8px 16px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(8px);
`;

export default AnimatedImage;

