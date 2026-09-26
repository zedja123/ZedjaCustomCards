--
--Fire King Sanctfire Kuranix
--scripted by Zedja
local s,id=GetID()
function s.initial_effect(c)
	--If your monster(s) that was originally FIRE is destroyed by battle or card effect: You can Special Summon this card from your GY (if it was there when the monster was destroyed) or hand (even if not), and if you do, it gains ATK equal to the combined ATK those destroyed monsters had, until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You cannot Special Summon monsters, except FIRE monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_FIRE) end)
	c:RegisterEffect(e2)
end
function s.spconfilter(c,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsOriginalAttribute(ATTRIBUTE_FIRE) and c:IsPreviousControler(tp)
		and not c:IsPreviousLocation(LOCATION_SZONE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not (c:IsLocation(LOCATION_GRAVE) and eg:IsContains(c)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local atk=0
	for tc in eg:Filter(s.spconfilter,nil,tp):Iter() do
		atk=atk+(tc:IsPreviousLocation(LOCATION_MZONE) and tc:GetPreviousAttackOnField() or tc:GetBaseAttack())
	end
	if atk>0 then
		--It gains ATK equal to the combined ATK those destroyed monsters had, until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
